package anifire.browser.core
{
	public class ActionGroup
	{
		
		
		private var _id:String = "";
		
		private var _name:String = "";
		
		private var _actions:Array;
		
		public function ActionGroup(param1:String, param2:String)
		{
			this._actions = new Array();
			super();
			this._id = param1;
			this._name = param2;
		}
		
		public function get id() : String
		{
			return this._id;
		}
		
		public function get name() : String
		{
			return this._name;
		}
		
		public function addAction(param1:Action) : void
		{
			this._actions.push(param1);
			param1.actionGroup = this;
		}
		
		public function get actions() : Array
		{
			return this._actions.concat();
		}
	}
}
