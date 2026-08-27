package anifire.creator.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	import mx.preloaders.IPreloaderDisplay;

	/**
	 * The CCPreloader class displays the progress bar during the Creator
	 * application's boot process.
	 */
	public class CCPreloader extends Sprite implements IPreloaderDisplay
	{
		[Embed(source="/styles/images/preloader/loading_logo.png")]
		private static var imgLogo:Class;

		[Embed(source="/styles/images/preloader/loading_track.png")]
		private static var imgBarTrack:Class;

		[Embed(source="/styles/images/preloader/loading_fill.png")]
		private static var imgBarFill:Class;

		private static const LOGO_WIDTH:int = 188;
		private static const LOGO_HEIGHT:int = 36;
		private static const TRACK_WIDTH:int = 224;
		private static const TRACK_HEIGHT:int = 12;
		private static const FILL_WIDTH:int = 221;
		private static const FILL_HEIGHT:int = 8;
		private static const MARGIN:int = 20;
		private var _preloader:Sprite;
		private var _stageWidth:Number = 0;
		private var _stageHeight:Number = 0;
		private var _trackX:Number;
		private var _trackY:Number;
		private var _fillX:Number;
		private var _fillY:Number;
		private var _rendered:Boolean;
		private var _barFillBitmapData:BitmapData;
		private var _fillSprite:Sprite;

		public function CCPreloader()
		{
			super();
		}

		public function set preloader(obj:Sprite) : void
		{
			this._preloader = obj;
			obj.addEventListener(Event.COMPLETE, this.handleLoadComplete);
			obj.addEventListener(ProgressEvent.PROGRESS, this.handleLoadProgress);
			obj.addEventListener(FlexEvent.INIT_COMPLETE, this.handleInitComplete);
			obj.addEventListener(RSLEvent.RSL_ERROR, this.handleRslError);
		}

		public function initialize() : void {}

		private function show() : void
		{
			if (this.stageWidth == 0 && this.stageHeight == 0) {
				try {
					this.stageWidth = stage.stageWidth;
					this.stageHeight = stage.stageHeight;
				} catch (e:Error) {
					stageWidth = loaderInfo.width;
					stageHeight = loaderInfo.height;
				}
				if (this.stageWidth == 0 && this.stageHeight == 0) {
					return;
				}
			}
			if (!this._rendered) {
				this.createChildren();
			}
		}

		protected function createChildren() : void
		{
			var hw:Number = this._stageWidth * 0.5;
			var hh:Number = this._stageHeight * 0.5;
			var logoOffsetY:Number = (LOGO_HEIGHT + MARGIN + TRACK_HEIGHT) * 0.5;
			var logoImg:Bitmap = new imgLogo();
			var logoX:Number = hw - LOGO_WIDTH * 0.5;
			var logoY:Number = hh - logoOffsetY;
			graphics.beginBitmapFill(logoImg.bitmapData, new Matrix(1, 0, 0, 1, logoX, logoY), false, true);
			graphics.drawRect(logoX, logoY, LOGO_WIDTH, LOGO_HEIGHT);
			graphics.endFill();
			this._trackX = hw - TRACK_WIDTH * 0.5;
			this._trackY = hh - logoOffsetY + LOGO_HEIGHT + MARGIN;
			this._fillX = hw - FILL_WIDTH * 0.5;
			this._fillY = this._trackY + (TRACK_HEIGHT - FILL_HEIGHT) * 0.5;
			var trackImg:Bitmap = new imgBarTrack();
			graphics.beginBitmapFill(trackImg.bitmapData, new Matrix(1, 0, 0, 1, this._trackX, this._trackY), false, true);
			graphics.drawRect(this._trackX, this._trackY, TRACK_WIDTH, TRACK_HEIGHT);
			graphics.endFill();
			var fillImg:Bitmap = new imgBarFill();
			this._barFillBitmapData = fillImg.bitmapData;
			this._fillSprite = new Sprite();
			this._fillSprite.x = this._fillX;
			this._fillSprite.y = this._fillY;
			addChild(this._fillSprite);
			this._rendered = true;
		}

		protected function updateProgress(value:Number) : void
		{
			this._fillSprite.graphics.clear();
			this._fillSprite.graphics.beginBitmapFill(this._barFillBitmapData, null, false, true);
			this._fillSprite.graphics.drawRect(0, 0, FILL_WIDTH * value, FILL_HEIGHT);
			this._fillSprite.graphics.endFill();
		}

		private function handleLoadProgress(event:ProgressEvent) : void
		{
			if (!this._rendered) {
				this.createChildren();
			}
			this.updateProgress(event.bytesLoaded / event.bytesTotal);
		}

		private function handleLoadComplete(event:Event) : void {}

		private function handleInitComplete(event:FlexEvent) : void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}

		private function handleRslError(event:Event) : void {}

		public function get backgroundColor() : uint
		{
			return 0xFFFFFF;
		}
		public function set backgroundColor(value:uint) : void {}

		public function get backgroundAlpha() : Number
		{
			return 0;
		}
		public function set backgroundAlpha(value:Number) : void {}

		public function get backgroundImage() : Object
		{
			return undefined;
		}
		public function set backgroundImage(value:Object) : void {}

		public function get backgroundSize() : String
		{
			return "";
		}
		public function set backgroundSize(value:String) : void {}

		public function get stageWidth() : Number
		{
			return this._stageWidth;
		}
		public function set stageWidth(value:Number) : void
		{
			this._stageWidth = value;
		}

		public function get stageHeight() : Number
		{
			return this._stageHeight;
		}
		public function set stageHeight(value:Number) : void
		{
			this._stageHeight = value;
		}
	}
}
