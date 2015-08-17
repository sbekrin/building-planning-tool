part of planner;

/*
 *	Toolbox class.
 *
 *	Simple wrapper for DOM element.
 */
class Widget extends InterfaceBlock
{
	// Defaults
	static const CLASS				= 'gui-widget',
				 TITLE_CLASS		= 'gui-widget-title',
				 CONTENT_CLASS		= 'gui-widget-content',
				 SNAP_LEFT			= 0,
				 SNAP_LEFT_CLASS	= 'gui-widget-snapped-left',
				 SNAP_RIGHT			= 1,
				 SNAP_RIGHT_CLASS	= 'gui-widget-snapped-right',
				 SNAP_TOP			= 2,
				 SNAP_TOP_CLASS		= 'gui-widget-snapped-top',
				 SNAP_BOTTOM		= 3,
				 SNAP_BOTTOM_CLASS	= 'gui-widget-snapped-bottom';
	
	// Data
	Element _node;
	
	// Constructor
	Widget (String titleContent, { String id, int horizal, int vertical })
	{
		this._node = new Element.html('''<section class="$CLASS">
			<h1 class="$TITLE_CLASS">$titleContent</h1>
			<div class="$CONTENT_CLASS"></div>
		</section>''');
		
		if (id != null)
		{
			this._node.id = id;
		}
		
		if (horizal != null)
		{
			switch (horizal)
			{
				case SNAP_LEFT: this._snapLeft(); break;
				case SNAP_RIGHT: this._snapRight(); break;
				default: throw new Exception('Invalid snap horizal flag');
			}
		}
		else
		{
			this._snapLeft();
		}
		
		if (vertical != null)
		{
			switch (vertical)
			{
				case SNAP_TOP: this._snapTop(); break;
				case SNAP_BOTTOM: this._snapBottom(); break;
				default: throw new Exception('Invalid snap vertical flag');
			}
		}
		else
		{
			this._snapTop();
		}
		
		this._compose();
	}
	
	// Getters
	Element get node => this._node;
	Element get _title => this._node.querySelector('.$TITLE_CLASS');
	Element get _content => this._node.querySelector('.$CONTENT_CLASS');
	
	// Snap modes
	void _snapLeft ( )
	{
		this._node.classes.add(SNAP_LEFT_CLASS);
		this._node.classes.remove(SNAP_RIGHT_CLASS);
	}
	
	void _snapRight ( )
	{
		this._node.classes.add(SNAP_RIGHT_CLASS);
		this._node.classes.remove(SNAP_LEFT_CLASS);
	}
	
	void _snapTop ( )
	{
		this._node.classes.add(SNAP_TOP_CLASS);
		this._node.classes.remove(SNAP_BOTTOM_CLASS);
	}
	
	void _snapBottom ( )
	{
		this._node.classes.add(SNAP_BOTTOM_CLASS);
		this._node.classes.remove(SNAP_TOP_CLASS);
	}
	
	// Add elements to box
	void add (Element element, { bool dividerRequired })
	{
		Element contentBlock = this._node.querySelector('.$CONTENT_CLASS');
		
		contentBlock.children.add(element);
		
		if (dividerRequired == true)
		{
			contentBlock.children.add(new HRElement());
		}
	}
	
	// Remove toolbox
	void remove ( )
	{
		this._node.remove();
	}
}