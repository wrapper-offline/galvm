package anifire.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * Deprecated
	 */
	public class UtilErrorLogger extends EventDispatcher
	{
		public static const FATAL_EVENT_LOGGED:String = "FATAL_EVENT_LOGGED";
		public static const ERROR_EVENT_LOGGED:String = "ERROR_EVENT_LOGGED";
		public static const LOG_SENT_COMPLETE:String = "LOG_SENT_COMPLETE";
		public static const LOG_SENT_FAIL:String = "LOG_SENT_FAIL";
		public static const SOURCE_FVM:String = "SOURCE_FVM";
		public static const SOURCE_PLAYER:String = "SOURCE_PLAYER";

		private static var _instance:UtilErrorLogger = null;

		public function UtilErrorLogger()
		{
			super();
		}

		public static function getInstance() : UtilErrorLogger
		{
			if (!_instance) {
				_instance = new UtilErrorLogger();
			}
			return _instance;
		}

		public function set movieId(_unused:String) : void
		{
		}

		public function get movieId() : String
		{
			return "";
		}

		public function appendDebug(_unused:String) : void
		{
		}

		public function appendError(_unused:Error) : void
		{
		}

		public function appendCustomError(_unused:String, _unused2:Error = null, _unused3:Object = null) : void
		{
		}

		public function fatal(_unused:String) : void
		{
		}

		public function error(_unused:String) : void
		{
		}

		public function info(_unused:String) : void
		{
		}

		private function getFlashVars() : String
		{
			return "";
		}

		private function prepareModel() : Object
		{
			return new Object();
		}

		public function getEncryptedDebugInfo(_unused:Boolean = false, param2:Boolean = false, _unused3:String = "") : String
		{
			return "";
		}

		private function get debugInfo() : String
		{
			return "";
		}

		public function get systemInfo() : String
		{
			return "";
		}

		public function get flashPlayerInfo() : String
		{
			return "";
		}

		public function get browserInfo() : String
		{
			return "";
		}

		private function sendLog(_unused:Boolean = false) : void
		{
		}

		private function onSendLogComplete(_unused:Event) : void
		{
		}

		private function onSendLogError(_unused:Event) : void
		{
		}

		public function copyLog() : void
		{
		}

		public function set source(_unused:String) : void
		{
		}
	}
}
