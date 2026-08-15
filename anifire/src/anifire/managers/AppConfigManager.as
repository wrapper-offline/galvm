package anifire.managers
{
	import flash.net.URLVariables;
	import mx.core.FlexGlobals;

	/**
	 * The AppConfigManager singleton class keeps track of the application
	 * configuration.
	 */
	public class AppConfigManager
	{
		private static var __instance:AppConfigManager;
		protected var _properties:Object;

		public function AppConfigManager()
		{
			super();
			this.init();
		}

		public static function get instance() : AppConfigManager
		{
			if (!__instance) {
				__instance = new AppConfigManager();
			}
			return __instance;
		}

		protected function init() : void
		{
			this._properties = {};
			this.processAppParams();
		}

		/**
		 * Copies all app parameters into the config properties.
		 */
		public function processAppParams() : void
		{
			var appParameters:Object = FlexGlobals.topLevelApplication;
			this.setParamters(appParameters.parameters);
		}

		/**
		 * Copies all entries from an object into the config properties.
		 */
		public function setParamters(parameters:Object) : void
		{
			for (var prop:String in parameters) {
				this._properties[prop] = parameters[prop];
			}
		}

		public function getValue(property:String) : String
		{
			return this._properties[property];
		}

		public function setValue(property:String, value:String) : void
		{
			this._properties[property] = value;
		}

		/**
		 * Creates a <code>URLVariables</code> object containing all config
		 * properties.
		 */
		public function createURLVariables() : URLVariables
		{
			var variables:URLVariables = new URLVariables();
			for (var prop:String in this._properties) {
				variables[prop] = this._properties[prop];
			}
			return variables;
		}

		/**
		 * Appends all config properties to a <code>URLVariables</code> object.
		 */
		public function appendURLVariables(variables:URLVariables) : void
		{
			for (var prop:String in this._properties) {
				variables[prop] = this._properties[prop];
			}
		}
	}
}
