component accessors="true" singleton {

	/**
	 * --------------------------------------------------------------------------
	 * DI
	 * --------------------------------------------------------------------------
	 */
	property name="wirebox" inject="wirebox";
	property name="populator" inject="wirebox:populator";
	property name="bcrypt" inject="@BCrypt";
	property name="auth" inject="authenticationService@cbauth";
	
	/**
	 * Constructor
	 */
	function init() {
		// We are mocking only 1 user right now, update as you see fit
		variables.mockUsers = [
			{
				"id"       : 1,
				"fname"    : "admin",
				"lname"    : "admin",
				"email"    : "admin@coldbox.org",
				"password" : "admin"
			}
		];

		return this;
	}

	User function new() provider="User" {}

	User function retrieveUserById( required id ) {
		return populator.populateFromQuery(
			new(),
			queryExecute("SELECT * FROM tblloginusers WHERE id = ?",[id]),
			1
		)
	}

	function retrieveUserByUsername( required username ) {
		return populator.populateFromQuery(
			new(),
			queryExecute("SELECT * FROM tblloginusers WHERE Email = ?",[username]),
			1
		)
	}

	boolean function isValidCredentials( required username, required password ) {
		var oUser = retrieveUserByUsername(username);
		if(!oUser.isLoaded()){
			return false;
		}else {
			return bcrypt.checkPassword(password, oUser.getPassword());
		}
	}

	function create(required struct formData){
		queryExecute("INSERT INTO tblloginusers (Name,UsrName,Email,Password)
			VALUES (?, ?, ?, ?)",
			[
				arguments.formData.fullName,
				arguments.formData.userName,
				arguments.formData.email,
				bcrypt.hashPassword(arguments.formData.password) 
			],
			{
				result: 'local.result'
			}
		);
		return local.result.generatedkey;
	}

	function addUserToken(required struct formData, required number pin){
		var getUserId = queryExecute("SELECT id FROM tblloginusers WHERE Email = '#arguments.formData.userName#'");

		var getRstFromUserId = queryExecute("SELECT id FROM tblusertoken WHERE user_id = #getUserId.id#");
		if(getRstFromUserId.recordCount EQ 1){
			queryExecute("UPDATE tblusertoken 
			set  token_pin = ?, is_verified = 1 WHERE user_id = ? ",
			[arguments.pin,getUserId.id]);
		}else {
			queryExecute("INSERT INTO tblusertoken (user_id,token_pin)
				VALUES (?, ?)",
				[
					getUserId.id,
					arguments.pin
				]
			);
		}
		return getUserId.id;
		
	}

	function checkValidPin(required string loginPin, required number user_id){
		var success = '';
		var ValidPin = queryExecute("
			SELECT token_pin FROM tblusertoken WHERE token_pin = :token_pin AND user_id = :user_id",
			{token_pin = arguments.loginPin, user_id = arguments.user_id}	
		);
		if(ValidPin.recordCount eq 1){
			queryExecute("UPDATE tblusertoken 
			set is_verified = 0 WHERE user_id = ?",
			[arguments.user_id]);

			success = true;
		}else {
			success = false;
		}
		
		return success;

	}

	
	function updatePassword(required struct formData){
		queryExecute("UPDATE tblloginusers 
			set Password = ? WHERE Email = ?",
			[bcrypt.hashPassword(arguments.formData.newPassword),arguments.formData.userName]);
	}
	

	function validateUser(required string userId){
		queryExecute("UPDATE tblloginusers 
			set isVerified = 0 WHERE id = ?",
			[arguments.userId]);
	}
}
