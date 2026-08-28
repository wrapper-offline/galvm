package anifire.browser.interfaces
{
	import anifire.util.UtilHashBytes;
	
	public interface ICharProduct extends IProduct
	{
		
		
		function getLibraries() : UtilHashBytes;
		
		function get isCC() : Boolean;
		
		function get propImageData() : Object;
	}
}
