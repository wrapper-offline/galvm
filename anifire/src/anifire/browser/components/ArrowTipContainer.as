package anifire.browser.components
{
	import mx.core.mx_internal;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.Group;

	[DefaultProperty("content")]
	public class ArrowTipContainer extends SkinnableComponent
	{
		[SkinPart(required="true")]
		public var contentGroup:Group;
		protected var contentMXML:Array;
		[Bindable]
		public var offset:Number = 10;
		[Bindable]
		public var targetWidth:Number = 40;
		protected var _tipPosition:String = "above";
		
		public function ArrowTipContainer()
		{
			super();
		}

		[Bindable]
		public function get tipPosition() : String
		{
			return this._tipPosition;
		}
		public function set tipPosition(param1:String) : void
		{
			if(this._tipPosition != param1)
			{
				this._tipPosition = param1;
				invalidateSkinState();
			}
		}

		[Bindable]
		public function get content() : Array
		{
			if(this.contentGroup)
			{
				return this.contentGroup.mx_internal::getMXMLContent();
			}
			return this.contentMXML;
		}
		public function set content(param1:Array) : void
		{
			if(this.contentGroup)
			{
				this.contentGroup.mxmlContent = param1;
			}
			else
			{
				this.contentMXML = param1;
			}
		}
		
		override protected function getCurrentSkinState() : String
		{
			switch (this.tipPosition)
			{
				case "below":
					return "below";
				case "above":
			}
			return "above";
		} 
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if (instance == this.contentGroup)
			{
				this.contentGroup.mxmlContent = this.contentMXML;
				this.contentMXML = null;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
			if (instance == this.contentGroup)
			{
				this.contentMXML = this.contentGroup.mx_internal::getMXMLContent();
				this.contentGroup.mxmlContent = null;
			}
		}
		
	}
}