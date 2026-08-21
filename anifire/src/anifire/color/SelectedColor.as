package anifire.color
{
	public class SelectedColor
	{
		private var _areaName:String = "";
		private var _orgColor:uint;
		private var _dstColor:uint;

		public function SelectedColor(areaName:String, orgColor:uint = 4294967295, dstColor:uint = 4294967295)
		{
			super();
			this._areaName = areaName;
			this._orgColor = orgColor;
			this._dstColor = dstColor;
		}

		/**
		 * Color name.
		 */
		public function get areaName() : String
		{
			return this._areaName;
		}

		/**
		 * Original color to be replaced via shader.
		 */
		public function get orgColor() : uint
		{
			return this._orgColor;
		}

		/**
		 * Selected color value.
		 */
		public function get dstColor() : uint
		{
			return this._dstColor;
		}
	}
}
