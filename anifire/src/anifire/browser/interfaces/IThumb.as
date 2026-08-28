package anifire.browser.interfaces
{
	import anifire.util.UtilHashArray;
	
	public interface IThumb
	{
		
		
		function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void;
		
		function isThumbReady(param1:String = "") : Boolean;
		
		function loadImageData() : void;
		
		function deSerialize(param1:XML, param2:ITheme, param3:Boolean = false) : void;
		
		function deSerializeFacial(param1:XML, param2:ITheme, param3:int = -1, param4:int = 1) : void;
		
		function mergeThumb(param1:IThumb) : void;
		
		function get defaultAction() : IBehavior;
		
		function get handStyle() : String;
		
		function set handStyle(param1:String) : void;
		
		function get id() : String;
		
		function set id(param1:String) : void;
		
		function get imageData() : Object;
		
		function get theme() : ITheme;
		
		function set theme(param1:ITheme) : void;
		
		function get themeId() : String;
		
		function set themeId(param1:String) : void;
		
		function get xml() : XML;
		
		function get colorParts() : UtilHashArray;
		
		function get colorRef() : UtilHashArray;
		
		function get raceCode() : int;
		
		function get isCC() : Boolean;
		
		function mergeThumbByXML(param1:XML) : void;
		
		function mergeThumbWithFacialByXML(param1:XML) : void;
	}
}
