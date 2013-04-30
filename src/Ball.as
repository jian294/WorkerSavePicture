package
{
	import flash.display.Sprite;
	
	public class Ball extends Sprite
	{
		public function Ball()
		{
			graphics.beginFill(Math.random() * 0xFFFFFF);
			graphics.drawCircle(0,0, Math.random() * 30);
			graphics.endFill();
		}
	}
}