package anifire.util
{
	import anifire.event.LoadMgrEvent;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	public class UtilLoadMgr extends EventDispatcher
	{
		private static const STATUS_INITIALIZE:String = "initialize";
		private static const STATUS_ON_PROGRESS:String = "onProgress";
		private static const STATUS_END:String = "end";
		private static const MAX_DELAY:Number = 1000;
		private static const MIN_DELAY:Number = 1;
		private static const MAX_JOBS:Number = 2;
		private var _progresses:Dictionary = new Dictionary();
		private var _timer:Timer = new Timer(MIN_DELAY);
		private var _status:String = "initialize";
		private var _loaderQueue:Array;
		private var _byteArrayQueue:Array;
		private var _count:Number = 0;
		private var _tasks:Array = new Array();
		private var _extraData:Object;

		public function UtilLoadMgr()
		{
			super();
			this._loaderQueue = new Array();
			this._byteArrayQueue = new Array();
		}

		/**
		 * Adds <code>eventType</code> listener to <code>dispatcher</code>.
		 */
		public function addEventDispatcher(dispatcher:EventDispatcher, eventType:String) : void
		{
			if (this._status != STATUS_INITIALIZE) {
				throw new Error("Error in using load manager. Loader object cannot be added after load manager has already started.");
			}
			var loadMgr:UtilLoadMgr = new UtilLoadMgr();
			loadMgr._progresses[dispatcher] = 0;
			dispatcher.addEventListener(eventType, loadMgr.onEachComplete);
			loadMgr.commit();
			this.addLoadMgr(loadMgr);
		}

		public function setExtraData(value:Object) : void
		{
			this._extraData = value;
		}
		public function getExtraData() : Object
		{
			return this._extraData;
		}

		private function addLoadMgr(loadMgr:UtilLoadMgr) : void
		{
			this._progresses[loadMgr] = 0;
			loadMgr.addEventListener(LoadMgrEvent.ALL_COMPLETE, this.onEachComplete);
		}

		private function onEachComplete(event:Event) : void
		{
			var target:EventDispatcher = event.target as EventDispatcher;
			target.removeEventListener(event.type, this.onEachComplete);
			this._progresses[target] = 1;
			this._timer.delay = MIN_DELAY;
		}

		public function commit() : void
		{
			if (this._loaderQueue.length > 0) {
				this._count = 0;
				this.startNextTask();
			}
			this._status = STATUS_ON_PROGRESS;
			this._timer.addEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer.start();
		}

		private function forceCompleteAll() : void
		{
			this._timer.removeEventListener(TimerEvent.TIMER, this.onTimer);
			this._timer.stop();
			this.dispatchEvent(new LoadMgrEvent(LoadMgrEvent.ALL_COMPLETE));
			this._status = STATUS_END;
		}

		private function onTimer(event:Event) : void
		{
			if (this.isAllComplete()) {
				this.forceCompleteAll();
			} else {
				this._timer.delay = MAX_DELAY;
			}
		}

		private function isAllComplete() : Boolean
		{
			for (var _loc1_:Object in this._progresses) {
				if (this._progresses[_loc1_] < 1) {
					return false;
				}
			}
			return true;
		}

		public function addTask(param1:Loader, param2:ByteArray) : void
		{
			this._loaderQueue.push(param1);
			this._byteArrayQueue.push(param2);
		}

		private function startNextTask() : void
		{
			var loader:Loader = this._loaderQueue[this._count] as Loader;
			var bytes:ByteArray = this._byteArrayQueue[this._count] as ByteArray;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onTaskDone);
			loader.loadBytes(bytes);
		}

		private function onTaskDone(event:Event) : void
		{
			++this._count;
			if (this._count < this._loaderQueue.length) {
				this.startNextTask();
			} else {
				this.onComplete();
			}
		}

		private function onComplete() : void {}
	}
}
