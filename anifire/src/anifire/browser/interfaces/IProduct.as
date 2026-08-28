package anifire.browser.interfaces
{
	import anifire.util.UtilHashArray;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	public interface IProduct extends IEventDispatcher
	{
		
		
		function get uid() : String;
		
		function get id() : String;
		
		function get aid() : String;
		
		function get fileName() : String;
		
		function get name() : String;
		
		function get enable() : Boolean;
		
		function get thumbImageData() : Object;
		
		function get imageData() : Object;
		
		function get useImageAsThumb() : Boolean;
		
		function get raceCode() : int;
		
		function get colorRef() : UtilHashArray;
		
		function get sysTags() : Array;
		
		function set useImageAsThumb(param1:Boolean) : void;
		
		function toString() : String;
		
		function loadImageData() : void;
		
		function doDrag(param1:MouseEvent) : void;
	}
}
