package anifire.creator.models
{
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;

	public class MenuItemModel
	{
		public static const MENU_TYPE_NORMAL:int = 0;
		public static const MENU_TYPE_RADIO:int = 1;
		public static const MENU_TYPE_CHECKBOX:int = 2;
		public static const MENU_TYPE_SEPARATOR:int = 3;

		[Bindable]
		public var label:String;

		[Bindable]
		public var value:*;

		[Bindable]
		public var icon:Class;

		[Bindable]
		public var parentMenu:MenuItemModel;

		protected var _subMenu:ArrayCollection;

		protected var _selectable:Boolean = true;

		[Bindable]
		public var selectedIndex:int;

		[Bindable]
		public var menuType:int;

		[Bindable]
		public var enabled:Boolean = true;

		[Bindable]
		public var sortOrder:int;

		protected var _selected:Boolean;

		public function MenuItemModel(
			label:String,
			value:*,
			menuType:int = 0,
			subMenu:ArrayCollection = null,
			icon:Class = null
		)
		{
			super();
			this.menuType = menuType;
			this.label = label;
			this.value = value;
			this.subMenu = subMenu;
			this.icon = icon;
			if (menuType == MENU_TYPE_SEPARATOR) {
				this.enabled = false;
			}
		}

		public function get subMenu() : ArrayCollection
		{
			return this._subMenu;
		}
		[Bindable]
		public function set subMenu(value:ArrayCollection) : void
		{
			if (this._subMenu != value) {
				this._subMenu = value;
				if (this._subMenu) {
					for (var i:int = 0; i < this._subMenu.length; i++) {
						var item:MenuItemModel = this._subMenu.getItemAt(i) as MenuItemModel;
						item.parentMenu = this;
					}
				}
			}
		}

		public function hasSubMenu() : Boolean
		{
			return Boolean(this._subMenu) && this._subMenu.length > 0;
		}

		[Bindable]
		public function set selectable(value:Boolean) : void
		{
			if (this._selectable != value) {
				this._selectable = value;
			}
		}
		public function get selectable() : Boolean
		{
			return this._selectable && !this.subMenu;
		}

		public function get selectedItem() : *
		{
			if (this.subMenu) {
				if (this.selectedIndex > 0 && this.selectedIndex < this.subMenu.length) {
					return this.subMenu.getItemAt(this.selectedIndex);
				}
			}
			return null;
		}

		public function get selected() : Boolean
		{
			return this._selected;
		}
		[Bindable]
		public function set selected(value:Boolean) : void
		{
			if (this._selected != value) {
				this._selected = value;
			}
		}

		public function toggle() : void
		{
			switch (this.menuType) {
				case MENU_TYPE_NORMAL:
					break;
				case MENU_TYPE_RADIO:
					this.selected = true;
					if (this.parentMenu) {
						var subMenu:ArrayCollection = this.parentMenu.subMenu;
						for (var i:int = 0; i < subMenu.length; i++) {
							var item:MenuItemModel = subMenu.getItemAt(i) as MenuItemModel;
							if (Boolean(item) && item != this) {
								item.selected = false;
							}
						}
					}
					break;
				case MENU_TYPE_CHECKBOX:
					this.selected = !this.selected;
			}
		}
	}
}
