package anifire.creator.skins
{
	import flash.accessibility.*;
	import flash.debugger.*;
	import flash.display.*;
	import flash.errors.*;
	import flash.events.*;
	import flash.external.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.printing.*;
	import flash.profiler.*;
	import flash.system.*;
	import flash.text.*;
	import flash.ui.*;
	import flash.utils.*;
	import flash.xml.*;
	import mx.binding.*;
	import mx.core.IFlexModuleFactory;
	import mx.events.PropertyChangeEvent;
	import mx.filters.*;
	import mx.styles.*;
	import spark.components.ButtonBarButton;

	public class HButtonBarSkinInnerClass1 extends ButtonBarButton
	{

		private static var _skinParts:Object = {
			"iconDisplay":false,
			"labelDisplay":false
		};

		private var _88844982outerDocument:HButtonBarSkin;

		private var __moduleFactoryInitialized:Boolean = false;

		public function HButtonBarSkinInnerClass1()
		{
			super();
			this.buttonMode = true;
		}

		override public function set moduleFactory(param1:IFlexModuleFactory) : void
		{
			var factory:IFlexModuleFactory = param1;
			super.moduleFactory = factory;
			if(this.__moduleFactoryInitialized)
			{
				return;
			}
			this.__moduleFactoryInitialized = true;
			if(!this.styleDeclaration)
			{
				this.styleDeclaration = new CSSStyleDeclaration(null,styleManager);
			}
			this.styleDeclaration.defaultFactory = function():void
			{
				this.skinClass = CustomButtonBarButtonSkin;
			};
		}

		override public function initialize() : void
		{
			super.initialize();
		}

		[Bindable(event="propertyChange")]
		public function get outerDocument() : HButtonBarSkin
		{
			return this._88844982outerDocument;
		}

		public function set outerDocument(param1:HButtonBarSkin) : void
		{
			var _loc2_:Object = this._88844982outerDocument;
			if(_loc2_ !== param1)
			{
				this._88844982outerDocument = param1;
				if(this.hasEventListener("propertyChange"))
				{
					this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this,"outerDocument",_loc2_,param1));
				}
			}
		}
	}
}
