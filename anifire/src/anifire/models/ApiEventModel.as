package anifire.models
{
	public class ApiEventModel
	{
		public var eventName:String;
		public var callback:String;

		/**
		 * The `ApiEventModel` class represents an API event.
		 */
		public function ApiEventModel(eventName:String, callback:String)
		{
			super();
			this.eventName = eventName;
			this.callback = callback;
		}
	}
}
