package anifire.component
{
	import anifire.interfaces.IRegulatedProcess;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.setTimeout;

	/**
	 * The ProcessRegulator class handles the execution of a queue of
	 * <code>IRegulatedProcess</code> instances.
	 */
	public class ProcessRegulator extends EventDispatcher implements IRegulatedProcess
	{
		private const STATE_IDLE:String = "STATE_IDLE";
		private const STATE_IN_PROGRESS:String = "STATE_IN_PROGRESS";
		private const STATE_HOLD:String = "STATE_HOLD";
		private const STATE_COMPLETE:String = "STATE_COMPLETE";

		/** Queue of processes to execute. */
		private var _processes:Vector.<ProcessData>;

		/** Current process being executed if oneByOne mode is set to true. */
		private var _step:Number = 0;

		/** Whether processes should be executed sequentially instead of concurrently. */
		private var _oneByOne:Boolean = false;

		/** ??? */
		private var _interval:Number = 0;

		/** Current status of process execution. */
		private var _state:String;

		private var _numComplete:Number = 0;

		public function ProcessRegulator(target:IEventDispatcher = null)
		{
			super(target);
			this.reset();
		}

		/**
		 * Adds a process to the queue.
		 * @param process An <code>IRegulatedProcess</code> to add.
		 * @param eventType Event type to listen for in the process that
		 * signals completion.
		 */
		public function addProcess(process:IRegulatedProcess, eventType:String) : void
		{
			if (Boolean(process) && Boolean(eventType)) {
				var processExists:Boolean = false;
				for each (var data:ProcessData in this._processes) {
					if (data.process == process) {
						processExists = true;
						break;
					}
				}
				if (!processExists) {
					this._processes.push(new ProcessData(process, eventType));
				}
			}
		}

		/**
		 * Length of the process queue.
		 */
		public function get numProcess() : Number
		{
			return this._processes.length;
		}

		/**
		 * Number of processes that have finished execution.
		 */
		public function get progress() : Number
		{
			return this._numComplete;
		}

		/**
		 * Begins executing all processes in the queue.
		 * @param oneByOne Whether processes should be executed sequentially
		 * instead of concurrently.
		 * @param interval Unclear what this may have been added for. It's
		 * unused in all classes that implement <code>IRegulatedProcess</code>.
		 */
		public function startProcess(oneByOne:Boolean = false, interval:Number = 0) : void
		{
			this._oneByOne = oneByOne;
			this._interval = interval;
			if (0 == this._processes.length || this._state == this.STATE_COMPLETE) {
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			if (this._state != this.STATE_IDLE) {
				return;
			}
			this._state = this.STATE_IN_PROGRESS;
			if (oneByOne) {
				this.startNext();
			} else {
				for each (var data:ProcessData in this._processes) {
					data.process.addEventListener(data.eventType, this.onProcessComplete);
					data.process.startProcess(oneByOne, interval);
				}
			}
		}

		/**
		 * Clears the process queue and halts process execution, if ongoing.
		 */
		public function reset() : void
		{
			for each (var data:ProcessData in this._processes) {
				data.process.removeEventListener(data.eventType, this.onProcessComplete);
			}
			this._processes = new Vector.<ProcessData>();
			this._step = 0;
			this._oneByOne = false;
			this._interval = 0;
			this._state = this.STATE_IDLE;
			this._numComplete = 0;
		}

		private function startNext() : void
		{
			if (this._step < this._processes.length) {
				++this._step;
				this._processes[this._step - 1].process.addEventListener(this._processes[this._step - 1].eventType, this.onProcessComplete);
				this._processes[this._step - 1].process.startProcess(this._oneByOne, this._interval);
			}
		}

		private function onProcessComplete(event:Event) : void
		{
			IEventDispatcher(event.target).removeEventListener(event.type, this.onProcessComplete);
			++this._numComplete;
			var progEvent:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			progEvent.bytesLoaded = this._numComplete;
			progEvent.bytesTotal = this._processes.length;
			this.dispatchEvent(progEvent);
			if (this._numComplete == this._processes.length) {
				this._state = this.STATE_COMPLETE;
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			if (this._oneByOne) {
				if (this._state == this.STATE_IN_PROGRESS) {
					if (this._interval > 0) {
						setTimeout(this.startNext, this._interval);
					} else {
						this.startNext();
					}
				}
			}
		}
	}
}

import anifire.interfaces.IRegulatedProcess;

class ProcessData
{
	private var _process:IRegulatedProcess;
	private var _eventType:String;
	public var completed:Boolean = false;

	public function ProcessData(process:IRegulatedProcess, eventType:String)
	{
		super();
		this._process = process;
		this._eventType = eventType;
	}

	public function get process() : IRegulatedProcess
	{
		return this._process;
	}

	public function get eventType() : String
	{
		return this._eventType;
	}
}
