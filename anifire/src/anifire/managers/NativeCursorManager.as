package anifire.managers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.ui.MouseCursorData;

	/**
	 * The NativeCursorManager singleton class exposes methods that help
	 * manage the cursor style.<br/>
	 * <br/>
	 * When called, the <code>NativeCursorManager()</code> constructor
	 * registers all relevant cursor styles.
	 */
	public class NativeCursorManager
	{
		private static var _instance:NativeCursorManager;

		[Embed(source="../styles/images/busy_cursor/1.png")]
		private static const imgCursor1:Class;
		[Embed(source="../styles/images/busy_cursor/2.png")]
		private static const imgCursor2:Class;
		[Embed(source="../styles/images/busy_cursor/3.png")]
		private static const imgCursor3:Class;
		[Embed(source="../styles/images/busy_cursor/4.png")]
		private static const imgCursor4:Class;

		public function NativeCursorManager()
		{
			super();
			var cursor:MouseCursorData = new MouseCursorData();
			cursor.frameRate = 8;
			var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>();
			bitmaps.push((new imgCursor1() as Bitmap).bitmapData);
			bitmaps.push((new imgCursor2() as Bitmap).bitmapData);
			bitmaps.push((new imgCursor3() as Bitmap).bitmapData);
			bitmaps.push((new imgCursor4() as Bitmap).bitmapData);
			cursor.data = bitmaps;
			Mouse.registerCursor("busyCursor", cursor);
		}

		public static function get instance() : NativeCursorManager
		{
			if (!_instance) {
				_instance = new NativeCursorManager();
			}
			return _instance;
		}

		/**
		 * Sets the mouse cursor to the busy style.
		 */
		public function setBusyCursor() : void
		{
			Mouse.cursor = "busyCursor";
		}

		/**
		 * Sets the mouse cursor to the default <code>MouseCursor.AUTO</code>
		 * style.
		 */
		public function removeBusyCursor() : void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
	}
}
