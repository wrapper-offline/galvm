package anifire.creator.models
{
	/**
	 * The CcRequireComponent class represents a list of all components of a
	 * certain type required by an action or facial.<br/>
	 * <br/>
	 * Actions requiring these components will not be listed for characters
	 * that are missing them. However, this behavior is seldom used in
	 * GoAnimate, as it lacks implementation in the
	 * <code>anifire.models.creator</code> theme models.
	 */
	public class CcRequireComponent
	{
		private var _componentType:String;
		private var _componentIds:Array;

		public function CcRequireComponent()
		{
			super();
		}

		public function get componentType() : String
		{
			return this._componentType;
		}

		public function get componentIds() : Array
		{
			return this._componentIds;
		}

		public function deserialize(xml:XML) : void
		{
			this._componentType = xml.@component_type;
			var text:String = xml.toString();
			this._componentIds = text.split(",");
		}
	}
}
