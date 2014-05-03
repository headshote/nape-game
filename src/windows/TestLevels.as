package  windows
{
	import examples.*;
	import flash.events.*;
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class TestLevels extends Levels_mc
	{
		
		public function TestLevels() 
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
				var text:String = "Sample " + (i+1);
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
					(parent as Main).Add(new BasicSimulation());
					break;
				case "lvl_1":
					(parent as Main).Add(new FixedDragging());
					break;
				case "lvl_2":
					(parent as Main).Add(new FilteringInteractions());
					break;
				case "lvl_3":
					(parent as Main).Add(new Constraints());
					break;
				case "lvl_4":
					(parent as Main).Add(new PerlinSquares());
					break;
				case "lvl_5":
					(parent as Main).Add(new SpatialQueries());
					break;
				case "lvl_6":
					(parent as Main).Add(new SoftBodies());
					break;
				case "lvl_7":
					(parent as Main).Add(new PyramidStressTest());
					break;
				case "lvl_8":
					(parent as Main).Add(new Viewports());
					break;
				case "lvl_9":
					(parent as Main).Add(new MarioGalaxyGravity());
					break;
				case "lvl_10":
					(parent as Main).Add(new OneWayPlatforms());
					break;
				case "lvl_11":
					(parent as Main).Add(new BodyFromGraphic());
					break;
				case "lvl_12":
					(parent as Main).Add(new DestructibleTerrain());
					break;
				case "lvl_13":
					//(parent as Main).Add(new Portals());
					break;					
			}
			(parent as Main).Remove(this);
		}
		
	}

}