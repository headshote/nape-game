package windows 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class OverLay extends OverLay_mc
	{
		
		public function OverLay() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			closeBtn.addEventListener(MouseEvent.CLICK, btnClicked);			
		}
		
		private function btnClicked(e:MouseEvent):void 
		{	
			for ( var i:int = 0; i < parent.numChildren; i++)
			{
				var chld:DisplayObject = parent.getChildAt(i);
				if ( chld != this )
					(parent as Main).Remove(chld);
			}
			(parent as Main).Add(new Menu());			
		}
		
	}
}