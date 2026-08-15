package anifire.util
{
	import anifire.event.ExtraDataEvent;
	import anifire.interfaces.IRegulatedProcess;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	public class ExtraDataLoader extends Loader implements IRegulatedProcess
	{
		public var extraData:*;
		private var _bytes:ByteArray;

		public function ExtraDataLoader()
		{
			super();
		}

		private function set bytes(value:ByteArray) : void
		{
			this._bytes = value;
		}

		override public function dispatchEvent(event:Event) : Boolean
		{
			var newEvent:ExtraDataEvent = new ExtraDataEvent(
				event.type,
				new Object(),
				this.extraData,
				event.bubbles,
				event.cancelable
			);
			return super.dispatchEvent(newEvent);
		}

		public function writeExternal(param1:IDataOutput) : void
		{
			param1.writeObject(this.extraData);
		}

		public function readExternal(param1:IDataInput) : void
		{
			this.extraData = param1.readObject();
		}

		override public function addEventListener(
			type:String,
			listener:Function, 
			useCapture:Boolean = false,
			priority:int = 0,
			_useWeakReference:Boolean = false
		) : void
		{
			super.addEventListener(type, listener, useCapture, priority, true);
		}

		public function startProcess(oneByOne:Boolean = false, interval:Number = 0) : void
		{
			this.loadBytes(this._bytes);
		}
	}
}
