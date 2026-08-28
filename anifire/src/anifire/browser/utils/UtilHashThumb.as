package anifire.browser.utils
{
	import anifire.browser.core.Thumb;
	import anifire.util.UtilHashMap;

	public class UtilHashThumb
	{
		// this seems veery similar to anifire.util.UtilHashArray
		// i think the two could be merged
		// TODO: merge them

		private var keyToIndexMap:UtilHashMap;
		private var indexToKeyMap:Vector.<String>;
		private var data:Vector.<Thumb>;

		public function UtilHashThumb()
		{
			super();
			this.keyToIndexMap = new UtilHashMap();
			this.indexToKeyMap = new Vector.<String>();
			this.data = new Vector.<Thumb>();
		}

		/**
		 * Add a thumbnail with a key.
		 */		
		public function push(key:String, thumb:Thumb, changeExisting:Boolean = true) : int
		{
			var index:int = 0;
			if (this.keyToIndexMap.containsKey(key))
			{
				if (changeExisting)
				{
					index = this.keyToIndexMap.getValue(key) as int;
					this.data[index] = thumb;
				}
			}
			else
			{
				index = int(this.data.length);
				this.data.push(thumb);
				this.indexToKeyMap.push(key);
				this.keyToIndexMap.put(key, index);
			}
			return index;
		}

		/**
		 * Removes a number of elements after a starting index.
		 */
		public function remove(startFrom:int, remove:int) : void
		{
			var index:int = 0;
			if (startFrom >= this.length || startFrom + remove - 1 >= this.length)
			{
				throw new Error("UtilHashArray index out of bound error. Index --> " + startFrom);
			}
			index = 0;
			while (index < remove)
			{
				this.keyToIndexMap.remove(this.indexToKeyMap[startFrom + index]);
				index++;
			}
			this.data.splice(startFrom, remove);
			this.indexToKeyMap.splice(startFrom, remove);
			// move the indexes in the keytoindexmap back
			index = startFrom;
			while (index < this.length)
			{
				this.keyToIndexMap.remove(this.indexToKeyMap[index]);
				this.keyToIndexMap.put(this.indexToKeyMap[index], index);
				index++;
			}
		}

		/**
		 * Removes an element with a specific key.
		 */
		public function removeByKey(key:String) : void
		{
			var index:int = this.getIndex(key);
			if (index != -1)
			{
				this.remove(index, 1);
			}
		}

		/**
		 * Appends a UtilHashThumb to the end of this UtilHashThumb.
		 */
		public function insert(UNUSEDPLEASEREMOVEME:int, utilHashThumb:UtilHashThumb, changeExisting:Boolean = true) : void
		{
			var index:int = 0;
			index = utilHashThumb.length - 1;
			while (index >= 0)
			{
				this.push(utilHashThumb.getKey(index), utilHashThumb.getValueByIndex(index), changeExisting);
				index--;
			}
		}

		/**
		 * Check if a key already exists.
		 */
		public function containsKey(param1:String) : Boolean
		{
			return this.keyToIndexMap.containsKey(param1);
		}

		/**
		 * Check if a thumbnail already exists.
		 */
		public function containsValue(param1:Thumb) : Boolean
		{
			var _loc2_:int = 0;
			while (_loc2_ < this.data.length)
			{
				if (this.data[_loc2_] == param1)
				{
					return true;
				}
				_loc2_++;
			}
			return false;
		}

		/**
		 * Gets a key from an index.
		 */
		public function getKey(index:int) : String
		{
			return this.indexToKeyMap[index];
		}

		/**
		 * Returns a list of all the keys.
		 */
		public function getKeys() : Vector.<String>
		{
			return this.indexToKeyMap;
		}

		/**
		 * Gets an index from a key.
		 */
		public function getIndex(key:String) : int
		{
			var _loc2_:* = this.keyToIndexMap.getValue(key);
			if (_loc2_ != null)
			{
				return int(_loc2_);
			}
			return -1;
		}

		/**
		 * Returns a Thumb at a key.
		 */
		public function getValueByKey(key:String) : Thumb
		{
			var index:* = this.keyToIndexMap.getValue(key);
			if (index != null)
			{
				return this.data[int(index)];
			}
			return null;
		}

		/**
		 * Returns a Thumb at an index.
		 */
		public function getValueByIndex(index:int) : Thumb
		{
			return this.data[index];
		}

		/**
		 * Replaces a Thumb at an index.
		 */
		public function replaceValueByIndex(index:int, newThumb:Thumb) : void
		{
			if (index >= this.length || index < 0)
			{
				throw new Error("index out of bound");
			}
			this.data[index] = newThumb;
		}

		/**
		 * Replaces a Thumb at a key.
		 */
		public function replaceValueByKey(key:String, newThumb:Thumb) : void
		{
			var index:* = this.keyToIndexMap.getValue(key);
			if (index == null)
			{
				throw new Error("key not exist!");
			}
			this.data[index as int] = newThumb;
		}

		/**
		 * Returns the length of this UtilHashThumb.
		 */
		public function get length() : int
		{
			return this.data.length;
		}

		/**
		 * Clears this UtilHashThumb.
		 */
		public function removeAll() : void
		{
			this.keyToIndexMap.clear();
			this.keyToIndexMap = new UtilHashMap();
			this.indexToKeyMap.splice(0, this.indexToKeyMap.length);
			this.indexToKeyMap = new Vector.<String>();
			this.data.splice(0, this.data.length);
			this.data = new Vector.<Thumb>();
		}

		/**
		 * Returns all the Thumbs as an array.
		 */
		public function getArray() : Array
		{
			var _loc1_:Array = [];
			for each (var _loc2_:Thumb in this.data)
			{
				_loc1_.push(_loc2_);
			}
			return _loc1_;
		}

		/**
		 * Returns the length of this UtilHashThumb.
		 */
		public function getVector() : Vector.<Thumb>
		{
			return this.data;
		}

		/**
		 * Returns a clone of this UtilHashThumb.
		 */
		public function clone() : UtilHashThumb
		{
			var clone:UtilHashThumb = new UtilHashThumb();
			clone.data = this.data.concat();
			clone.indexToKeyMap = this.indexToKeyMap.concat();
			var index:int = 0;
			while (index < clone.indexToKeyMap.length)
			{
				clone.keyToIndexMap.put(clone.indexToKeyMap[index], index);
				index++;
			}
			return clone;
		}
	}
}
