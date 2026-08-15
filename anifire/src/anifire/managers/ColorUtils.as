package anifire.managers
{
	import anifire.component.EyeDropperScreenOverlay;

	/**
	 * The ColorUtils class contains methods that assist with the conversion
	 * of color values.<br/>
	 * <br/>
	 * honestly this doesn't even belong in managers but it's 14 years too late
	 * to do anything about it
	 */
	public class ColorUtils
	{
		public static var eyeDropperScreenOverlay:EyeDropperScreenOverlay;

		public function ColorUtils()
		{
			super();
		}

		/**
		 * Converts a color value to a hex code.
		 * @param color Color value
		 * @param base String to be prepended to the hex code (eg, "#" or "0x")
		 */
		public static function colorToHex(color:uint, base:String = "") : String
		{
			var fixed:uint = uint(0x0F000000 | color & 0xFFFFFF);
			var hex:String = fixed.toString(16);
			return base + hex.substring(1).toUpperCase();
		}

		/**
		 * Converts RGB values to a single color value.
		 */
		public static function rgbToColor(red:int, green:int, blue:int) : uint
		{
			return red << 16 | green << 8 | blue;
		}

		/**
		 * Converts a color value to its RGB values.
		 */
		public static function colorToRgb(color:uint) : Array
		{
			var rgbArray:Array = [];
			rgbArray.push(color >> 16 & 0xFF);
			rgbArray.push(color >> 8 & 0xFF);
			rgbArray.push(color & 0xFF);
			return rgbArray;
		}
	}
}
