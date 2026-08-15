package anifire.cc.view
{
	public class CcDecorationComponent extends CcComponent
	{

		public function CcDecorationComponent()
		{
			super();
		}

		override protected function setProperties() : void
		{
			super.setProperties();
			if(Boolean(loader) && Boolean(this.model) && Boolean(this.model.id))
			{
				loader.name = this.model.id;
			}
		}
	}
}
