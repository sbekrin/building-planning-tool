part of planner;

/**
 *	Menu Section item class
 *
 *	Provides DOM wrapper and usefull tools for
 *	items maniulation
 */
class MenuSectionGroupLabelItem extends MenuSectionGroupItem
{
	/*
	 * Defaults
	 */
	static const ICON_CLASS			= 'gui-menu-section-content-group-item-icon',
				 TITLE_CLASS		= 'gui-menu-section-content-group-item-title',
				 SHORTCUT_CLASS		= 'gui-menu-section-content-group-item-shortcut',
				 VERTICAL_CLASS		= 'vertical';
	
	/*
	 * Constructor
	 */
	MenuSectionGroupLabelItem (Object content, Action action, { Icon icon,
																bool beta,
																Map<String, Object> data,
																bool vertical/* TODO: , var disableWhen, var enableWhen */ })
	{
		if (icon != null)
		{
			this._node.children.add(new Element.html('<span class="$ICON_CLASS">${icon}</span>'));
			
			this.icon = icon;
		}
		
		this._node.children.add(new Element.html('<span class="$TITLE_CLASS">$content</span>'));
		//..children.add(new Element.html('<span class="$SHORTCUT_CLASS">${(action.hotkey == null) ? '' : Key.toReadable(action.hotkey.toList())}</span>'));
		
		if (vertical == true)
		{
			this._node.classes.add(VERTICAL_CLASS);
		}
		
		if (beta == true)
		{
			this.text += '<sup title="This feature still in development and may be unstable">&beta;</sup>';
		}
		
		if (data != null)
		{
			this.draggableData = data;
		}
		
		if (action != null)
		{
			void clickHandler (Event event)
			{
				action.execute();
			}
			
			this._node
			..on['click'].listen(clickHandler)
			..on['touchend'].listen(clickHandler);
		}
		
		this._compose();
	}
	
	/*
	 * Getters
	 */
	Element get _iconNode	=> this._node.querySelector('.$ICON_CLASS');
	Element get _titleNode	=> this._node.querySelector('.$TITLE_CLASS');
	String	get text		=> this._titleNode.innerHtml;
	
	/*
	 * Setters
	 */
	set icon (Icon icon)	=> this._iconNode.innerHtml = icon.toString();
	set text (String text)	=> this._titleNode.innerHtml = text;
}