/**************************************************************************************/
/*    G. Batigne
/*      18/10/2018
/**************************************************************************************/

class itemSelector extends GUIObject { // Class creating and handling a selection menu.

  int nValues;
  int fontSize;
  int itemSelected;
  String[] itemList;
  boolean expandList = false; // Is the list of choices is requested to be displayed or not.
  boolean isUpdated = false; // Has the choice changed or not. 
  Button[] selectionList;
  
  itemSelector(int x, int y, int w, int h, String[] sl) {
    super(x,y,w,h);
    nValues = sl.length;
    itemList = sl;
    fontSize = 12;
    
    createSelectionList();
  }
   
  void createSelectionList() { // Create the different choices from a list. One Button object per choice.
    // If the list contains nValues choices, an array of nValues+1 Button objects is created.
    // The first element corresponds to the chosen value which is always displayed. 
    selectionList = new Button[nValues+1];
    Button b = new Button(posx,posy,Width,Height,"Select Port",fontSize);
    selectionList[0] = b;
    for (int i=0; i<nValues; ++i) {
      b = new Button(posx,posy+(i+1)*Height,Width,Height,itemList[i],fontSize);
      selectionList[i+1] = b;
      selectionList[i+1].setStrokeColor(selectionList[i+1].getBkgColor());
    }
  }
  
  void setItem(int i) {
    setText(selectionList[i+1].getText());
    itemSelected = i;
  }
  
  void setText(String t) { // Set the displayed text.
    selectionList[0].setText(t);
  }
  
  String getText() { // Get the displayed text.
    return selectionList[0].getText();
  }
  
  void switchColors() { // Switching color when the layout of the software is switched.
    for (int i=0; i<nValues+1; ++i) {
      selectionList[i].switchColors();
      if (i>0) selectionList[i].setStrokeColor(selectionList[i].getBkgColor());
    }
  }
  
  void draw() { // Draw the first Button (choice) and the list of choices only when needed.
    selectionList[0].draw();
    if (expandList) {
      for (int i=0; i<nValues; ++i) {
        selectionList[i+1].draw();
      }
    }
  }
  
  int getItemSelected() {
    return itemSelected;
  }
  
  boolean isNewSelection() { // Return true if the selection has changed.
    boolean b = isUpdated;
    isUpdated = false;
    return b;
  }
  
  boolean isExpanded() { // Return true if all choices are displayed.
    return expandList;
  }
  
  boolean buttonPressed(int x, int y) {
    // When a button is pressed, 
    boolean stateChanged = false;
    if (expandList) { // When the list is expanded only.
      for (int i=0; i<nValues; ++i) {
        if (selectionList[i+1].isMouseOver(x,y)) {
          selectionList[0].setText(selectionList[i+1].getText());
            // A choice has been made, so the text of the first element is changed.
          itemSelected = i;
          isUpdated = true;
          expandList = !expandList; // Close the list after a choice.
          stateChanged = true; // Open/Close status has changed. Value returned to 
              // the main program to know is the display has to be completely redrawn
              // or not.
        }
      }
    }
    if (selectionList[0].isMouseOver(x,y)) {
      expandList = !expandList;
      stateChanged = true;
    }
    return stateChanged;
  }
  
  void overButton(int x, int y) { // Trigger action on the Button items if the mouse is over. 
    for (int i=0; i<nValues+1; ++i) {
      if (i==0 || expandList) { // Test alway on first button (selected value) and selection buttons only when the list is expanded.
        selectionList[i].overButton(x,y);
      }
    }
  }
}
