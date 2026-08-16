package anifire.creator.components
{
	import anifire.creator.skins.ConfirmPopUpSkin;
	import anifire.event.StudioEvent;
	import anifire.util.UtilDict;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import mx.core.FlexGlobals;
	import mx.events.PropertyChangeEvent;
	import spark.components.Label;
	import spark.components.Panel;
	import spark.components.supportClasses.ButtonBase;
	import spark.events.PopUpEvent;
	import spark.primitives.BitmapImage;
	
	public class ConfirmPopUp extends DefaultPopUpContainer
	{
		public static const CONFIRM_POPUP_NO_ICON:int = 0;
		public static const CONFIRM_POPUP_INFO:int = 1;
		public static const CONFIRM_POPUP_ALERT:int = 2;
		public static const CONFIRM_POPUP_ERROR:int = 3;

		[Embed(source="/styles/images/TEMP_POPUP/imgAlert.png")]
		public static const imgAlert:Class;
		[Embed(source="/styles/images/TEMP_POPUP/imgConfirm.png")]
		public static const imgConfirm:Class;
		[Embed(source="/styles/images/TEMP_POPUP/imgError.png")]
		public static const imgError:Class;

		public var confirmButton:ButtonBase;
		public var cancelButton:ButtonBase;
		public var closeButton:ButtonBase;
		public var panel:Panel;
		public var messageLabel:Label;
		public var iconDisplay:BitmapImage;

		protected var _iconType:int = 2;
		protected var _showConfirmButton:Boolean = true;
		protected var _showCancelButton:Boolean = true;
		protected var _showCloseButton:Boolean = true;

		public function ConfirmPopUp()
		{
			super();
			setStyle("fontSize", 14);
			setStyle("skinClass", ConfirmPopUpSkin);
		}

		public static function openDefaultPopUpWithLocale(message:String, title:String = null, owner:DisplayObjectContainer = null, modal:Boolean = true, closeCb:Function = null) : ConfirmPopUp
		{
			if (message) {
				message = UtilDict.toDisplay("go", message);
			}
			if (title) {
				title = UtilDict.toDisplay("go", title);
			}
			return openDefaultPopUp(message, title, owner, modal, closeCb);
		}

		public static function openDefaultPopUp(message:String, title:String = null, owner:DisplayObjectContainer = null, modal:Boolean = true, closeCb:Function = null) : ConfirmPopUp
		{
			var popup:ConfirmPopUp = new ConfirmPopUp();
			popup.createDefaultPopUp();
			popup.message = message;
			if (title) {
				popup.title = title;
			}
			if (closeCb != null) {
				popup.addEventListener(PopUpEvent.CLOSE, closeCb);
			}
			if (!owner) {
				owner = FlexGlobals.topLevelApplication as DisplayObjectContainer;
			}
			popup.open(owner, modal);
			return popup;
		}

		public function createDefaultPopUp() : void
		{
			this.showCloseButton = false;
			this.confirmText = UtilDict.toDisplay("go", "OK");
			this.cancelText = UtilDict.toDisplay("go", "Cancel");
		}

		[Bindable]
		public function get iconType() : int
		{
			return this._iconType;
		}
		public function set iconType(value:int) : void
		{
			if (this._iconType != value) {
				this._iconType = value;
				if (this.iconDisplay) {
					this.updateIconDisplay();
				}
			}
		}

		protected function updateIconDisplay() : void
		{
			switch (this._iconType) {
				case CONFIRM_POPUP_INFO:
					this.iconDisplay.source = imgConfirm;
					break;
				case CONFIRM_POPUP_ALERT:
					this.iconDisplay.source = imgAlert;
					break;
				case CONFIRM_POPUP_ERROR:
					this.iconDisplay.source = imgError;
					break;
				default:
					this.iconDisplay.source = null;
			}
		}

		[Bindable]
		public function get showConfirmButton() : Boolean
		{
			return this._showConfirmButton;
		}
		public function set showConfirmButton(value:Boolean) : void
		{
			this._showConfirmButton = value;
			if (this.confirmButton) {
				this.confirmButton.includeInLayout = value;
				this.confirmButton.visible = value;
			}
		}

		[Bindable]
		public function get showCancelButton() : Boolean
		{
			return this._showCancelButton;
		}
		public function set showCancelButton(value:Boolean) : void
		{
			this._showCancelButton = value;
			if (this.cancelButton) {
				this.cancelButton.includeInLayout = value;
				this.cancelButton.visible = value;
			}
		}

		[Bindable]
		public function get showCloseButton() : Boolean
		{
			return this._showCloseButton;
		}
		public function set showCloseButton(value:Boolean) : void
		{
			this._showCloseButton = value;
			if (this.closeButton) {
				this.closeButton.includeInLayout = value;
				this.closeButton.visible = value;
			}
		}

		override public function set confirmText(value:String) : void
		{
			super.confirmText = value;
			if (this.confirmButton) {
				this.confirmButton.label = value;
			}
		}

		override public function set cancelText(value:String) : void
		{
			super.cancelText = value;
			if (this.cancelButton) {
				this.cancelButton.label = value;
			}
		}

		override public function set message(value:String) : void
		{
			super.message = value;
			if (this.messageLabel) {
				this.messageLabel.text = value;
			}
		}

		override protected function partAdded(partName:String, instance:Object) : void
		{
			if (instance == this.confirmButton) {
				this.confirmButton.label = confirmText;
				this.confirmButton.includeInLayout = this.showConfirmButton;
				this.confirmButton.visible = this.showConfirmButton;
				this.confirmButton.addEventListener(MouseEvent.CLICK, this.onConfirmButtonClick);
			} else if (instance == this.cancelButton) {
				this.cancelButton.label = cancelText;
				this.cancelButton.includeInLayout = this.showCancelButton;
				this.cancelButton.visible = this.showCancelButton;
				this.cancelButton.addEventListener(MouseEvent.CLICK, this.onCancelButtonClick);
			} else if (instance == this.closeButton) {
				this.closeButton.includeInLayout = this.showCloseButton;
				this.closeButton.visible = this.showCloseButton;
				this.closeButton.addEventListener(MouseEvent.CLICK, this.onCloseButtonClick);
			} else if (instance == this.messageLabel) {
				this.messageLabel.text = message;
			} else if (instance == this.iconDisplay) {
				this.updateIconDisplay();
			}
		}

		override protected function partRemoved(partName:String, instance:Object) : void
		{
			if (instance == this.confirmButton) {
				this.confirmButton.removeEventListener(MouseEvent.CLICK, this.onConfirmButtonClick);
			} else if (instance == this.cancelButton) {
				this.cancelButton.removeEventListener(MouseEvent.CLICK, this.onCancelButtonClick);
			} else if (instance == this.closeButton) {
				this.closeButton.removeEventListener(MouseEvent.CLICK, this.onCloseButtonClick);
			}
		}

		protected function onConfirmButtonClick(event:MouseEvent) : void
		{
			this.dispatchEvent(new StudioEvent(StudioEvent.POPUP_CONFIRM));
			confirm();
		}

		protected function onCancelButtonClick(event:MouseEvent) : void
		{
			cancel();
		}

		protected function onCloseButtonClick(event:MouseEvent) : void
		{
			cancel();
		}
	}
}
