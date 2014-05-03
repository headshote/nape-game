package levels 
{
	import levels.common.*;
	import nape.geom.*;
	import utils.*;
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Level4  extends Game
	{
		
		public function Level4() 
		{
			super( Vec2.get(0, 700) );
		}
		
		override protected function init():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;				
			
			readLevelData(new Level_4());
		}
		
		override protected function updates():void
		{
			var sc:Number = GameNumbers.currentScale;
			controlCamera(_actor.getPos().x + ( 800 + 400 * (sc-2) )* (sc-1) , _actor.getPos().y + ( 600 + 300 * (sc-2) ) * (sc-1), sc, 0);
			
			_actor.update();			
		}	
	}

}