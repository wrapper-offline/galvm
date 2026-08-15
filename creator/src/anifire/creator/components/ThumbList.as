package anifire.creator.components
{
	import flash.events.KeyboardEvent;
	import spark.components.List;

	public class ThumbList extends List
	{

		private static var _skinParts:Object = {
			"scroller":false,
			"dropIndicator":false,
			"dataGroup":false
		};

		public function ThumbList()
		{
			super();
		}

		override protected function keyDownHandler(param1:KeyboardEvent) : void
		{
		}
	}
}
