package anifire.interfaces
{
	import flash.events.IEventDispatcher;

	public interface IRegulatedProcess extends IEventDispatcher
	{
		function startProcess(oneByOne:Boolean = false, interval:Number = 0) : void;
	}
}
