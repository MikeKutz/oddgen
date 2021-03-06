/*
 * Copyright 2015-2016 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev

import com.jcabi.aspects.Loggable
import com.jcabi.log.Logger
import java.awt.BorderLayout
import java.awt.Component
import java.awt.Dimension
import java.awt.GridBagConstraints
import java.awt.GridBagLayout
import java.awt.Insets
import java.awt.Toolkit
import java.awt.event.ActionEvent
import java.awt.event.ActionListener
import java.awt.event.WindowEvent
import java.util.HashMap
import java.util.List
import javax.swing.BorderFactory
import javax.swing.DefaultComboBoxModel
import javax.swing.JButton
import javax.swing.JComboBox
import javax.swing.JDialog
import javax.swing.JLabel
import javax.swing.JPanel
import javax.swing.JScrollPane
import javax.swing.JTextField
import javax.swing.ScrollPaneConstants
import javax.swing.SwingUtilities
import org.oddgen.sqldev.dal.DatabaseGeneratorDao
import org.oddgen.sqldev.model.DatabaseGenerator
import org.oddgen.sqldev.resources.OddgenResources
import javax.swing.JCheckBox

@Loggable(value=LoggableConstants.DEBUG)
class GenerateDialog extends JDialog implements ActionListener {
	private List<DatabaseGenerator> dbgens

	private JButton buttonGenerateToWorksheet
	private JButton buttonGenerateToClipboard
	private JButton buttonCancel

	private JPanel paneParams;
	private int paramPos = -1;
	private HashMap<String, Component> params = new HashMap<String, Component>()

	private static String[] BOOLEAN_TRUE = #["true", "yes", "ja", "oui", "si", "1"]
	private static String[] BOOLEAN_FALSE = #["false", "no", "nein", "non", "no", "0"]

	def static createAndShow(Component parent, List<DatabaseGenerator> dbgens) {
		SwingUtilities.invokeLater(new Runnable() {
			override run() {
				GenerateDialog.createAndShowWithinEventThread(parent, dbgens);
			}
		});
	}

	def private static createAndShowWithinEventThread(Component parent, List<DatabaseGenerator> dbgens) {
		// create and layout the dialog
		val dialog = new GenerateDialog(parent, dbgens)
		dialog.pack
		// center dialog
		val dim = Toolkit.getDefaultToolkit().getScreenSize();
		dialog.setLocation(dim.width / 2 - dialog.getSize().width / 2, dim.height / 2 - dialog.getSize().height / 2);
		dialog.visible = true
	}

	new(Component parent, List<DatabaseGenerator> dbgens) {
		super(SwingUtilities.windowForComponent(parent), '''«OddgenResources.getString("DIALOG_TITLE")» - «dbgens.get(0).name»''',
			ModalityType.APPLICATION_MODAL)
		this.dbgens = dbgens
		val pane = this.getContentPane();
		pane.setLayout(new GridBagLayout());
		val c = new GridBagConstraints();

		// description pane
		val paneDescription = new JPanel(new BorderLayout());
		val textDescription = new JLabel('''<html><p>«dbgens.get(0).description»</p></html>''')
		paneDescription.add(textDescription, BorderLayout.NORTH);
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 2;
		c.insets = new Insets(10, 20, 0, 20); // top, left, bottom, right
		c.anchor = GridBagConstraints.NORTH;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 0;
		c.weighty = 0;
		pane.add(paneDescription, c)

		// Parameters pane
		paneParams = new JPanel(new GridBagLayout())
		addParam(OddgenResources.getString("DIALOG_OBJECT_TYPE_PARAM"))
		addParam(OddgenResources.getString("DIALOG_OBJECT_NAME_PARAM"))
		for (param : dbgens.get(0).params.keySet) {
			param.addParam
		}
		val scrollPaneParameters = new JScrollPane(paneParams)
		scrollPaneParameters.verticalScrollBarPolicy = ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED
		scrollPaneParameters.horizontalScrollBarPolicy = ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER
		scrollPaneParameters.border = BorderFactory.createEmptyBorder;
		c.gridx = 0;
		c.gridy = 1;
		c.gridwidth = 2;
		c.insets = new Insets(10, 10, 0, 10); // top, left, bottom, right
		c.anchor = GridBagConstraints.NORTH;
		c.fill = GridBagConstraints.BOTH;
		c.weightx = 1;
		c.weighty = 1;
		pane.add(scrollPaneParameters, c)

		// Buttons pane
		val panelButtons = new JPanel(new GridBagLayout())
		buttonGenerateToWorksheet = new JButton(OddgenResources.getString("DIALOG_GENERATE_TO_WORKSHEET_BUTTON"))
		buttonGenerateToWorksheet.addActionListener(this);
		c.gridx = 0;
		c.gridy = 0;
		c.gridwidth = 1;
		c.insets = new Insets(0, 0, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonGenerateToWorksheet, c);
		buttonGenerateToClipboard = new JButton(OddgenResources.getString("DIALOG_GENERATE_TO_CLIPBOARD_BUTTON"));
		buttonGenerateToClipboard.addActionListener(this);
		c.gridx = 1;
		c.insets = new Insets(0, 10, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonGenerateToClipboard, c);
		buttonCancel = new JButton(OddgenResources.getString("DIALOG_CANCEL_BUTTON"));
		buttonCancel.addActionListener(this);
		c.gridx = 2;
		c.gridy = 0;
		c.gridwidth = 1;
		c.insets = new Insets(0, 10, 0, 0); // top, left, bottom, right
		c.fill = GridBagConstraints.NONE;
		c.weightx = 0;
		c.weighty = 0;
		panelButtons.add(buttonCancel, c);
		c.gridx = 1;
		c.gridy = 2;
		c.gridwidth = 1;
		c.insets = new Insets(30, 10, 10, 10); // top, left, bottom, right
		c.anchor = GridBagConstraints.EAST
		c.fill = GridBagConstraints.NONE
		c.weightx = 0;
		c.weighty = 0;
		pane.add(panelButtons, c);
		pane.setPreferredSize(new Dimension(600, 375));
		SwingUtilities.getRootPane(buttonGenerateToWorksheet).defaultButton = buttonGenerateToWorksheet

	}

	def private isCheckBox(String name) {
		val dbgen = dbgens.get(0)
		val lovs = dbgen.lovs.get(name)
		if (lovs != null && lovs.size > 0 && lovs.size < 3) {
			val entry = lovs.get(0).toLowerCase
			if (BOOLEAN_TRUE.findFirst[it == entry] != null || BOOLEAN_FALSE.findFirst[it == entry] != null) {
				return true
			}
		}
		return false
	}
	
	def private addParam(String name) {
		paramPos++
		val c = new GridBagConstraints();
		val label = new JLabel(name)
		val dbgen = dbgens.get(0)
		c.gridx = 0
		c.gridy = paramPos
		c.gridwidth = 1
		c.insets = new Insets(10, 10, 0, 0) // top, left, bottom, right
		c.anchor = GridBagConstraints.WEST
		c.fill = GridBagConstraints.HORIZONTAL
		c.weightx = 0
		c.weighty = 0
		paneParams.add(label, c);
		c.gridx = 1
		c.insets = new Insets(10, 10, 0, 10); // top, left, bottom, right
		c.weightx = 1
		if (name == OddgenResources.getString("DIALOG_OBJECT_TYPE_PARAM")) {
			val textObjectType = new JTextField(dbgen.objectType)
			textObjectType.editable = false
			textObjectType.enabled = false
			paneParams.add(textObjectType, c);
		} else if (name == OddgenResources.getString("DIALOG_OBJECT_NAME_PARAM")) {
			val textObjectName = new JTextField(if(dbgens.size > 1) "***" else dbgen.objectName)
			textObjectName.editable = false
			textObjectName.enabled = false
			paneParams.add(textObjectName, c);
		} else {
			val lovs = dbgen.lovs.get(name)
			if (name.isCheckBox) {
				val checkBox = new JCheckBox("")
				val entry = lovs.findFirst[it == dbgen.params.get(name)].toLowerCase
				checkBox.selected = BOOLEAN_TRUE.findFirst[it == entry] != null
				paneParams.add(checkBox, c)
				params.put(name, checkBox)
				if (dbgen.isRefreshable) {
					checkBox.addActionListener(this)
				}
				if (dbgen.lovs.get(name).size == 1) {
					checkBox.enabled = false
				}				
			} else if (lovs != null && lovs.size > 0) {
				val comboBoxModel = new DefaultComboBoxModel<String>();
				for (lov : lovs) {
					comboBoxModel.addElement(lov)
				}
				val comboBox = new JComboBox<String>(comboBoxModel)
				comboBox.selectedItem = dbgen.params.get(name)
				paneParams.add(comboBox, c)
				params.put(name, comboBox)
				if (dbgen.isRefreshable) {
					comboBox.addActionListener(this)
				}
				if (dbgen.lovs.get(name).size == 1) {
					comboBox.editable = false
					comboBox.enabled = false
				}
			} else {
				val textField = new JTextField(dbgen.params.get(name))
				paneParams.add(textField, c);
				params.put(name, textField)
			}
		}
	}

	def updateDatabaseGenerators(boolean first) {
		for (dbgen : dbgens.filter[!first || it == dbgens.get(0)]) {
			for (name : dbgen.params.keySet) {
				val component = params.get(name)
				var String value
				if (component instanceof JTextField) {
					value = component.text
				} else if (component instanceof JCheckBox) {
					val lovs = dbgens.get(0).lovs.get(name)
					if (lovs.size == 1) {
						value = lovs.get(0)
					} else {
						if (component.selected && BOOLEAN_TRUE.findFirst[it == lovs.get(0).toLowerCase] != null) {
							value = lovs.get(0)
						} else {
							value = lovs.get(1)
						}
					}
				} else {
					value = (component as JComboBox<String>).selectedItem as String
				}
				dbgen.params.put(name, value)
			}
		}
	}

	def exit() {
		this.dispatchEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING));
	}

	def generateToWorksheet() {
		updateDatabaseGenerators(false)
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		OddgenNavigatorController.instance.generateToWorksheet(dbgens, conn)
	}

	def generateToClipboard() {
		updateDatabaseGenerators(false)
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		OddgenNavigatorController.instance.generateToClipboard(dbgens, conn)
	}
	
	def refreshLovs() {
		// do everything in the event thread to avoid strange UI behavior
		updateDatabaseGenerators(true)
		val conn = (OddgenNavigatorManager.instance.navigatorWindow as OddgenNavigatorWindow).connection
		val dao = new DatabaseGeneratorDao(conn)
		val dbgen = dbgens.get(0)
		dao.refresh(dbgen)
		for (name : params.keySet) {
			val component = params.get(name)
			if (component instanceof JCheckBox) {
				val checkBox = component
				val selected = checkBox.selected
				Logger.debug(this, "selected value for checkBox %1$s before change: %2$s (enabled: %3$s)", name, selected, checkBox.enabled)
				var Boolean newSelected 
				if (dbgen.lovs.get(name).size == 1) {
					newSelected = BOOLEAN_TRUE.findFirst[it == dbgen.lovs.get(name).get(0)] != null
					checkBox.enabled = false
				} else {
					newSelected = selected
					checkBox.enabled = true
				}
				checkBox.selected = newSelected
				Logger.debug(this, "selected value for checkBox %1$s after change: %2$s (enabled: %3$s)", name, checkBox.selected, checkBox.enabled)
			} else if (component.class.name == "javax.swing.JComboBox") {
				// do not use instanceof for JComboBox to avoid rawtypes warning
				val comboBox = component as JComboBox<String>
				comboBox.removeActionListener(this)
				val model = comboBox.model as DefaultComboBoxModel<String>
				val selected = model.selectedItem as String
				Logger.debug(this, "selected value for comboBox %1$s before change: %2$s (enabled: %3$s)", name, selected, comboBox.enabled)
				model.removeAllElements
				for (value : dbgen.lovs.get(name)) {
					model.addElement(value)
				}
				var String newSelectedValue
				if (selected == null || dbgen.lovs.get(name).findFirst[it == selected] == null) {
					Logger.debug(this, "changing value, first value in list");
					newSelectedValue = model.getElementAt(0)
				} else {
					Logger.debug(this, "keeping value");
					newSelectedValue = selected
				}
				model.selectedItem = newSelectedValue
				if (model.size > 1) {
					comboBox.editable = true
					comboBox.enabled = true
				} else {
					comboBox.editable = false
					comboBox.enabled = false
				}
				Logger.debug(this, "selected value for comboBox %1$s after change: %2$s (enabled: %3$s)", name, model.selectedItem, comboBox.enabled)
				comboBox.addActionListener(this)
			}
		}
	}

	override actionPerformed(ActionEvent e) {
		if (e.getSource == buttonCancel) {
			exit
		} else if (e.getSource == buttonGenerateToWorksheet) {
			val Runnable runnable = [|generateToWorksheet]
			val thread = new Thread(runnable)
			thread.name = "oddgen Worksheet Generator"
			thread.start
			exit
		} else if (e.getSource == buttonGenerateToClipboard) {
			val Runnable runnable = [|generateToClipboard]
			val thread = new Thread(runnable)
			thread.name = "oddgen Clipboard Generator"
			thread.start
			exit
		} else if (e.getSource.class.name == "javax.swing.JComboBox" || e.getSource instanceof JCheckBox) {
			// do not use instanceof for JComboBox to avoid rawtypes warning
			refreshLovs()
		}
	}

}
