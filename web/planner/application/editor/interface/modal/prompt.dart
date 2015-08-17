part of planner;

class PromptDialog extends Modal
{
	/*
	 * Defaults
	 */
	static const OK_ACTION		= 'onPromptDialogOk';
	
	/*
	 * Constructor
	 */
	PromptDialog (String title, String placeholder): super (title)
	{
		this._contentNode.children.add(new Textbox(placeholder: placeholder, width: Textbox.STRETCH).node);
		this._controlsNode.children.add(new Button('Ok', new Action('modal-dialog-ok', () => this.close())).node);
	}
}