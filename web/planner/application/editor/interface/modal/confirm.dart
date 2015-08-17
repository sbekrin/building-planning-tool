part of planner;

class ConfirmDialog extends Modal
{
	/*
	 * Defaults
	 */
	static const OK_ACTION		= 'onConfirmDialogOk',
				 CANCEL_ACTION	= 'onConfirmDialogCancel';
	
	/*
	 * Constructor
	 */
	ConfirmDialog (String title, String message): super (title)
	{
		this._contentNode.children.add(new ParagraphElement()..text = message);
		this._controlsNode.children.add(new Button('Ok', new Action('modal-dialog-ok', () => this.close())).node);
		this._controlsNode.children.add(new Button('Cancel', new Action('modal-dialog-cancel', () => this.close())).node);
	}
}