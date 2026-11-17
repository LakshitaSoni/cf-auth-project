/**
 * I am a new handler
 */
component{

	property name="userService" inject="UserService";
	property name="messageBox" inject="messageBox@cbmessagebox";
	

	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";
	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};

	/**
	IMPLICIT FUNCTIONS: Uncomment to use

	function preHandler( event, rc, prc, action, eventArguments ){
	}
	function postHandler( event, rc, prc, action, eventArguments ){
	}
	function aroundHandler( event, rc, prc, targetAction, eventArguments ){
		// executed targeted action
		arguments.targetAction( event );
	}
	function onMissingAction( event, rc, prc, missingAction, eventArguments ){
	}
	function onError( event, rc, prc, faultAction, exception, eventArguments ){
	}
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventArguments ){
	}
	*/

	/**
	 * new
	 */
	function new( event, rc, prc ){
		event.setView( "registration/new" );
	}

	/**
	 * create
	 */
	function create( event, rc, prc ){
		var formData = event.getExcept(["event","fieldnames","format"]);
		var generatedkey = userService.create(formData);
		var sendUserValidateMail = sendValidationMail(generatedkey,formData);
		/* flash.put("notice",{
			type: "success",
			message: "The user #encodeForHTML(rc.fullName)# with id : #generatedkey# was created !"
		}); */
		// event.setView( "registration/create" );
		messageBox.success("The user #encodeForHTML(rc.fullName)# with id : #generatedkey# was created !")
		relocate(uri = "/");
	}


	
	
	function sendValidationMail( event, rc, prc ){
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
		var validateLink = 'http://127.0.0.1:64064/sessions/validateUser/?user=#arguments.event#';
		savecontent variable="mailBody" {
			writeOutput("<h2>Hello</h2>");
			writeOutput("<p>Click on this link to validate : <strong>#validateLink#</strong></p>");
			writeOutput("<p>Thank You.</p>");
		};
		var mailSubject = "User Verefication Mail !";
		var mailSetting = settings.MAIL;
		var fromAddress = mailSetting.mail_from_name & ' <' & mailSetting.mail_from_mail & '>';
		var mailService = new mail(
			to          = trim(arguments.rc.email),
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
	}


	
	
	
	



}
