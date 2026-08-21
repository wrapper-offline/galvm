package anifire.creator.utils
{
	import anifire.creator.models.CcComponentThumb;

	/**
	 * The ComponentThumbFilter class stores the filter function for component
	 * thumbnails.
	 */
	public class ComponentThumbFilter
	{
		private static function _null_func(thumb:CcComponentThumb) : Boolean
		{
			return true;
		}
		private var _func:Function = _null_func;

		public function ComponentThumbFilter()
		{
			super();
		}

		public function get filter() : Function
		{
			return this._func;
		}

		public function set filter(value:Function) : void
		{
			if (value == null) {
				value = _null_func;
			}
			this._func = value;
		}
	}
}
