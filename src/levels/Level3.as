package levels
{
	import levels.common.*;
	import nape.geom.*;
	import utils.*;
	
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Level3 extends Game
	{
		public function Level3()
		{
			super( Vec2.get(0, 300) );
		}
		
		override protected function init():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;				
			
			readLevelData(new Level_3());
		}
		
		override protected function updates():void
		{
			controlCamera(_mousePoint.x, _mousePoint.y, GameNumbers.currentScale, 0);			
		}		
	}
}