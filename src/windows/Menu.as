package  windows
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Menu extends Menu_mc
	{
		
		public function Menu() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			btn_examples.addEventListener(MouseEvent.CLICK, btnClicked);			
			btn_start.addEventListener(MouseEvent.CLICK, btnClicked);			
		}
		
		private function btnClicked(e:MouseEvent):void 
		{
			switch ( e.currentTarget.name )
			{
				case "btn_start":
					(parent as Main ).Add(new Levels());
					break;
				case "btn_examples":
					(parent as Main ).Add(new TestLevels());
					break;
			}
			(parent as Main ).Remove(this);		
		}		
	}
}