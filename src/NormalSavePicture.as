package
{
	import com.adobe.images.JPEGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class NormalSavePicture extends Sprite
	{
		[Embed(source="tmp.jpg")]    
		private var image:Class;   
		
		private var m_bitmap: Bitmap;
		
		private var jpgEncoder: JPEGEncoder;
		
		private var m_tf: TextField;
		
		public function NormalSavePicture()
		{
			if ( stage )
				init();
			else
				addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init(e:Event = null): void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			m_bitmap = new image();
			
			addChild(new RandomBalls());
			addChild(new Stats());
			
			m_tf = new TextField();
			addChild(m_tf);
			m_tf.x = 200;
			m_tf.width = 200;
			m_tf.backgroundColor = 0x00FFFFFF;
			m_tf.background = true;
			m_tf.text = "这是没用worker的\n点击舞台开始压缩图片";
			
			jpgEncoder = new JPEGEncoder();
			stage.addEventListener(MouseEvent.CLICK, _onClick);
			
			
			
		}
		
		
		private function _onClick(e: MouseEvent): void
		{
			m_tf.appendText("\n开始压缩");
			jpgEncoder.encode(m_bitmap.bitmapData);
			m_tf.appendText("\n压缩完毕");
		}
	}
}