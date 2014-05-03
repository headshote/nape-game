package windows 
{
	import flash.display.*;
	import flash.events.*;
	import levels.common.*;
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
			restartBtn.addEventListener(MouseEvent.CLICK, btnClicked);			
		}
		
		private function btnClicked(e:MouseEvent):void 
		{	
			switch ( e.currentTarget.name )
			{
				case "closeBtn":
					for ( var i:int = 0; i < parent.numChildren; i++)
					{
						var chld:DisplayObject = parent.getChildAt(i);
						if ( chld != this )
							(parent as Main).Remove(chld);
					}
					(parent as Main).Add(new Menu());	
					break;
				case "restartBtn":
					for ( i = 0; i < parent.numChildren; i++)
					{
						chld = parent.getChildAt(i);
						if ( chld is Game )
							chld["restart"]();
					}
					break;
			}
		}
		
	}
}