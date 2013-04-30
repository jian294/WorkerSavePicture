package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class RandomBalls extends Sprite
	{
		private var balls: Array ;
		public function RandomBalls()
		{
			if ( stage )
				init();
			else
				addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init(e:Event = null): void
		{
			this.mouseChildren = false;
			this.mouseEnabled = false;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			balls = new Array();
			var ball: Ball;
			for( var i: int = 0; i < 2000; i ++)
			{
				ball = new Ball();
				balls.push(ball);
				addChild(ball);
			}
			stage.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
		}
		
		private function _onEnterFrame(e: Event): void
		{
			var len: int = balls.length;
			var ball: Ball;
			for(var i: int = 0; i < len; i ++)
			{
				ball = balls[i];
				ball.x = stage.stageWidth * Math.random();
				ball.y = stage.stageHeight * Math.random();
			}
		}
	}
}