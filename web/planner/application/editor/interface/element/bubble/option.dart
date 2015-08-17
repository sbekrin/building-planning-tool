part of planner;

/**
 * 
 */
class ContextBubbleOption
{
	/*
	 * Defaults
	 */
	static const CLASS				= 'context-bubble-option',
				 LABEL_CLASS		= 'context-bubble-option-label';
	
	/*
	 * Data
	 */
	final String label;
	final Action action;
	final Icon icon;
	
	/*
	 * Constructor
	 */
	ContextBubbleOption (String this.label, Action this.action, Icon this.icon);
}