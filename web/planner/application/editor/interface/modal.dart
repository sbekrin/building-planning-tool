part of planner;

abstract class Modal extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const
				 CLASS			= 'gui-modal-box',
				 WRAP_CLASS		= 'gui-modal-box-wrapper',
				 TITLE_CLASS	= 'gui-modal-box-title',
				 CONTENT_CLASS	= 'gui-modal-box-content',
				 CONTROLS_CLASS	= 'gui-modal-box-controls',
				 
				 // Events
				 DONE_EVENT		= 'onModalDone';
	
	/*
	 * Constructor
	 */
	Modal (String title)
	{
		this._node = new Element.html('''
			<section class="$WRAP_CLASS">
				<div class="$CLASS">
					<h1 class="$TITLE_CLASS"></h1>
					<div class="$CONTENT_CLASS"></div>
					<div class="$CONTROLS_CLASS"></div>
				</div>
			</section>
		''');
		
		this._compose();
		
		this.title = title;
		
		this.show();
	}
	
	/*
	 * Getters
	 */
	Element get _titleNode		=> this._node.querySelector('.$TITLE_CLASS');
	Element get _contentNode	=> this._node.querySelector('.$CONTENT_CLASS');
	Element get _controlsNode	=> this._node.querySelector('.$CONTROLS_CLASS');
	String	get title			=> this._titleNode.text;
	ElementEvents get on		=> this._node.on;
	
	/*
	 * Setters
	 */
	set title (String title)		=> this._titleNode.text = title;
	
	/**
	 * Shows box
	 */
	void show ( )
	{ 
		document.body.children.add(this._node);
		
		Hotkey.enabled = false;
	}
	
	/**
	 * Hides box
	 */
	void hide ( )
	{
		document.body.children.remove(this._node);
		
		Hotkey.enabled = true;
	}
	
	/**
	 * Destroys box
	 */
	void close ( )
	{
		List<Element> elements = this._contentNode.querySelectorAll('input');
		
		this._node.dispatchEvent(new CustomEvent(DONE_EVENT, detail: { 'inputs': elements }));
		
		this.hide();
		this.removeNode();
	}
}