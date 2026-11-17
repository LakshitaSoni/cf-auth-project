/**
 * I am a new handler
 */
component{

	property name="messageBox" inject="messageBox@cbmessagebox"; 
	property name="auth" inject="authenticationService@cbauth";
	property name="userService" inject="UserService";


	/** 	
	 * new
	 */
	function new( event, rc, prc ){
		event.setView( "sessions/new" );
	}

	function checkPin( event, rc, prc ){
		event.setView( "sessions/newPin" );
	}

	function forgetPassword(event, rc, prc){
		event.setView( "sessions/passwordReset" );
	}

	
	/**
	 * ResetPassword
 	*/
	function ResetPasswordFrm( event, rc, prc){
		event.setView( "sessions/passwordResetForm" );
	}
	
	

	/**
	 * create
	 */
	function create( event, rc, prc ){
		try {
			var settings = {
				mail={
					'mail_from_name'  : getSystemSetting( "MAIL_FROM_NAME" ),
					'mail_from_mail'  : getSystemSetting( "MAIL_FROM_MAIL" ),
					'mail_server'  : getSystemSetting( "MAIL_SERVER" ),
					'mail_username'  : getSystemSetting( "MAIL_USERNAME" ),
					'mail_password'  : getSystemSetting( "MAIL_PASSWORD" ),
					'mail_port'  : getSystemSetting( "MAIL_PORT" ),
					'mail_ssl'  : getSystemSetting( "MAIL_SSL" ),
					'mail_tls'  : getSystemSetting( "MAIL_TLS" )
				}
			}
			auth.authenticate(rc.userName, rc.userPassword);
			var loginPin = randRange(1001, 9999, "CFMX_COMPAT");
			var token = userService.addUserToken(rc, loginPin);
			event.setPrivateValue( "User_id", token);
			savecontent variable="mailBody" {
				writeOutput("<h2>Hello, #rc.userName# </h2>");
				writeOutput("<p>You are trying to logged in . If it's you then login with this pin number: <strong>#loginPin#</strong></p>");
				writeOutput("<p>Thank You.</p>");
			};
			var mailSubject = "Login Pin!";
			var mailSetting = settings.MAIL;
			var fromAddress = mailSetting.mail_from_name & ' <' & mailSetting.mail_from_mail & '>';
			var mailService = new mail(
				to          = trim(rc.userName),
				from        = fromAddress,
				server		= mailSetting['mail_server'],
				username	= mailSetting['mail_username'],
				password	= mailSetting['mail_password'],
				port		= mailSetting['mail_port'],
				useTLS		= mailSetting['mail_tls'],
				useSSL		= mailSetting['mail_ssl'],
				subject     = mailSubject,
				type        = "html",
				body        = mailBody
			);
			var hh = mailService.send();
			/* messageBox.success("Welcome back #rc.userName#");
			return relocate(uri = "/");   */
			relocate("sessions.checkPin");
		} catch (InvalidCredentials e) {
			messageBox.warn(e.message);
			return relocate(uri = "/login");
		}
	}


	/**
	 * delete
	 */
	function delete( event, rc, prc ){
		auth.logout();
		messageBox.info("You have been successfuly logged out !");
		return relocate(uri = "/");  
	}

	function checkValidPin( event, rc, prc ){
		var result = userService.checkValidPin(rc.pin, prc.oCurrentUser.getId());
		if(result eq true){
			messageBox.success("You have successfully logged in !");
			return relocate(uri = "/");
		}else {
			messageBox.error("You have entered wrong pin !");
			return relocate(uri = "/login");
		}
	}

	
	/**
	 * resetPassword
  	 */
	function resetPassword( event, rc, prc ){
		try {
			var settings = {
				mail={
					'mail_from_name'  : getSystemSetting( "MAIL_FROM_NAME" ),
					'mail_from_mail'  : getSystemSetting( "MAIL_FROM_MAIL" ),
					'mail_server'  : getSystemSetting( "MAIL_SERVER" ),
					'mail_username'  : getSystemSetting( "MAIL_USERNAME" ),
					'mail_password'  : getSystemSetting( "MAIL_PASSWORD" ),
					'mail_port'  : getSystemSetting( "MAIL_PORT" ),
					'mail_ssl'  : getSystemSetting( "MAIL_SSL" ),
					'mail_tls'  : getSystemSetting( "MAIL_TLS" )
				}
			}
			var passResetLink = "http://127.0.0.1:64064/sessions/ResetPasswordFrm";
			savecontent variable="mailBody" {
				writeOutput("<h2>Hello, #rc.userName# </h2>");
				writeOutput("<p>Click on this link to reset your password <strong>#passResetLink#</strong></p>");
				writeOutput("<p>Thank You.</p>");
			};
			var mailSubject = "Login Pin!";
			var mailSetting = settings.MAIL;
			var fromAddress = mailSetting.mail_from_name & ' <' & mailSetting.mail_from_mail & '>';
			var mailService = new mail(
				to          = trim(rc.userName),
				from        = fromAddress,
				server		= mailSetting['mail_server'],
				username	= mailSetting['mail_username'],
				password	= mailSetting['mail_password'],
				port		= mailSetting['mail_port'],
				useTLS		= mailSetting['mail_tls'],
				useSSL		= mailSetting['mail_ssl'],
				subject     = mailSubject,
				type        = "html",
				body        = mailBody
			);
			var hh = mailService.send();
			messageBox.success("Password reset link has be successfully send to your email !");
			return relocate(uri = "/login");
		} catch (InvalidCredentials e) {
			messageBox.warn(e.message);
			return relocate(uri = "/login");
		}
	}
	

	function updatePassword( event, rc, prc ){
		var formData = event.getExcept(["event","fieldnames","format"]);
		var generatedkey = userService.updatePassword(formData);
		messageBox.success("Password has been successfully reset !");
		return relocate(uri = "/login");
	}


	function validateUser( event, rc, prc ){
		var validateUser = userService.validateUser(url.user);
		messageBox.success("You has been successfully verified !");
		return relocate(uri = "/login");
	}
	
}
