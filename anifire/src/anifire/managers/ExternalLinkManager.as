package anifire.managers
{
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;

	/**
	 * The ExternalLinkManager singleton class exposes several methods that
	 * assist with page navigation.
	 */
	public class ExternalLinkManager
	{
		private static var __instance:ExternalLinkManager;
		public static const DEFAULT_WINDOW_ID:String = "_self";
		public static const BLANK_WINDOW_ID:String = "_blank";
		public static const EXIT_STUDIO_FUNCTION:String = "exitStudio";
		public static const SESSION_FIELD_KEY:String = "ifut";
		private static const UNDERSCORE_PATTERN:RegExp = /%5f/gi;
		private var _sessionVariables:URLVariables;

		public function ExternalLinkManager()
		{
			super();
			this.init();
		}

		public static function get instance() : ExternalLinkManager
		{
			if (!__instance) {
				__instance = new ExternalLinkManager();
			}
			return __instance;
		}

		/**
		 * Decodes session variables from the
		 * <code>ExternalLinkManager.SESSION_FIELD_KEY</code> parameter. It's unclear
		 * what this may have been used for.
		 */
		private function init() : void
		{
			this._sessionVariables = new URLVariables();
			var session:String = AppConfigManager.instance.getValue(SESSION_FIELD_KEY);
			if (session) {
				this._sessionVariables.decode(unescape(session));
			}
		}

		public function exitStudio() : void
		{
			ExternalInterface.call(EXIT_STUDIO_FUNCTION);
		}

		/**
		 * Navigates to a URL.
		 */
		public function navigate(url:String, target:String = "_self") : void
		{
			var _loc3_:URLRequest = new URLRequest(url);
			navigateToURL(_loc3_, target);
		}

		/**
		 * Navigates to a URL with the session variables.
		 */
		public function navigateWithSession(url:String, target:String = "_self") : void
		{
			var request:URLRequest = new URLRequest(url);
			var variables:URLVariables = new URLVariables();
			this.addSessionInfo(variables);
			navigateToURL(new URLRequest(url + this.createRequestQueryString(variables)),target);
		}

		/**
		 * Navigates to a URL with variables.
		 */
		public function navigateWithVariables(url:String, variables:URLVariables, post:Boolean = true, target:String = "_self") : void
		{
			var request:URLRequest = new URLRequest(url);
			this.addSessionInfo(variables);
			if (post) {
				request.method = URLRequestMethod.POST;
				request.data = variables;
				navigateToURL(request, target);
			} else {
				navigateToURL(new URLRequest(url + this.createRequestQueryString(variables)), target);
			}
		}

		/**
		 * Copies the session variables to a <code>URLVariables</code> object.
		 */
		private function addSessionInfo(copyTo:URLVariables) : void
		{
			for (var variable:String in this._sessionVariables) {
				copyTo[variable] = this._sessionVariables[variable];
			}
		}

		private function createRequestQueryString(variables:URLVariables) : String
		{
			return "?" + unescape(variables.toString());
		}
	}
}
