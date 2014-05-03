package  windows
{
	import flash.events.*;
	import levels.*;
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Levels extends Levels_mc
	{
		
		public function Levels() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			for ( var i:int = 0; i < 14; i++ )
			{
				this["lvl_" + i].addEventListener(MouseEvent.CLICK, btnClicked);
				var text:String = "Level " + (i+1);
				this["lvl_" + i].downState.getChildAt(1).text = text;
				this["lvl_" + i].upState.getChildAt(1).text = text;
				this["lvl_" + i].hitTestState.getChildAt(1).text = text;
				this["lvl_" + i].overState.getChildAt(1).text = text;
			}			
		}
		
		private function btnClicked(e:Event):void 
		{
			switch ( e.currentTarget.name )
			{
				case "lvl_0":
					(parent as Main).Add(new Level1());
					break;
				case "lvl_1":
					(parent as Main).Add(new Level2());
					break;
				case "lvl_2":
					(parent as Main).Add(new Level3());
					break;
				case "lvl_3":
					(parent as Main).Add(new Level4());
					break;
				case "lvl_4":
					(parent as Main).Add(new Level5());
					break;
				case "lvl_5":
					(parent as Main).Add(new Level6());
					break;
				case "lvl_6":
					
					break;
				case "lvl_7":
					
					break;
				case "lvl_8":
					
					break;
				case "lvl_9":
					
					break;
				case "lvl_10":
					
					break;
				case "lvl_11":
					
					break;
				case "lvl_12":
					
					break;
				case "lvl_13":
					
					break;					
			}
			(parent as Main).Remove(this);
		}
		
	}

}