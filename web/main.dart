import 'dart:html';
import 'package:dnd/dnd.dart';

//Define our task class
class Task {
  String description, tag;
  bool isCompleted;

  Task([this.description, this.tag, this.isCompleted]);
}


void main() {

  //Sets newly created tasks with default tag
  var defaultOption = OptionElement()
    ..value = '-1'
    ..text = 'Choose a tag';

  //Contains all of the tags within a master list
  var masterList = SelectElement()
    ..id = 'select-master';
  masterList.children.add(defaultOption);
  querySelector('#main').insertAdjacentElement('beforeEnd', masterList);

  querySelector('#new-tag').onClick.listen((e) { //Update existing tasks, adds new tag to list

    var tag = OptionElement()
      ..text = (querySelector('#tag-name') as TextInputElement).value;
    querySelector('#select-master').children.add(tag);

    for(var j = 0; j < 2; j ++) {

      /*
      Runs through 2 iterations to select all tag selection objects
      Tags that have default select go under tag-select class
      Others refer to tag-select-not-default
      */

      var existingSelect = (j == 0) ? querySelectorAll('.tag-select') : querySelectorAll('.tag-select-not-default');

      //Iterate through all task objects
      for (var i = 0; i < existingSelect.length; i ++) {
        //Store the most recent addition to the master list in temp
        var temp = querySelector('#select-master').children.last;
        var a = OptionElement();
        a.text = temp.text;
        a.value = (querySelector('#tag-color') as InputElement).value;
        //Add the tag to the selected task
        existingSelect[i].children.add(a);
      }
    }

    //Resets tag color and text values
    (querySelector('#tag-name') as TextInputElement).value = '';
    (querySelector('#tag-color') as TextInputElement).value = '#FFFFFF';
  });

  //Create new task on click
  querySelector('#new-task').onClick.listen((e) {
    addTask();
  });

  //Adds new task on enter button press too
  querySelector('#description-task').onKeyPress.listen((e) {
    if (e.keyCode == KeyCode.ENTER) {
      addTask();
    }
  });

}

void addTask() {

  var textInput = (querySelector('#description-task') as TextInputElement).value;
  if (textInput != '' && textInput.replaceAll(' ', '') != '') {

    //First task added removes note about adding tasks
    if (querySelector('#empty-list') != null) {
      querySelector('#empty-list').remove();
    }

    var task = Task(textInput, '', false);

    //Task container
    var container = Element.div()
      ..className = 'task';

    //Task description
    var description = Element.p()
      ..className = 'description'
      ..text = task.description;

    //Handle the task can be dragged by
    var handle = Element.div()
      ..className = 'drag'
      ..text = '⠿';

    //Checkbox
    var checkbox = CheckboxInputElement()
      ..className = 'completed';

    //Select tag
    var tagSelect = SelectElement()
      ..className = 'tag-select';


    //Add all tags from master list to newly created task
    var temp = querySelector('#select-master').children;
    temp.forEach((f) {
      var a = OptionElement();
      a.text = f.text;

      if ((f as OptionElement).value == '-1') {
        a.value = '-1';
      } else {
        a.value = (querySelector('#tag-color') as InputElement).value;
      }

      tagSelect.children.add(a);
    });

    //Change to rounded border style when picking a tag
    tagSelect.onChange.listen((e) {

      if (tagSelect.value != '-1') {
        tagSelect.style.color = '${tagSelect.value}';
        tagSelect.className = 'tag-select-not-default';
      } else {
        tagSelect.className = 'tag-select';
        tagSelect.style.color = '#FEF9EF';
      }

    });


    //Remove button
    var remove = Element.p()
      ..text = '✖'
      ..className = 'remove';

    //Add as children to main div
    container.children.add(handle);
    container.children.add(checkbox);
    container.children.add(description);
    container.children.add(remove);
    container.children.add(tagSelect);

    //Add task relative to the div element
    querySelector('.container-contents').insertAdjacentElement('beforeBegin', container);

    //Remove task container when x is clicked
    remove.onClick.listen((e) {

      container.remove();

      //Display no notes text if no tasks are present
      if (querySelector('.task') == null) {
        var p = Element.p()
          ..text = 'Looks like there aren\'t any tasks yet..'
          ..id = 'empty-list';
        querySelector('.container-contents').insertAdjacentElement('beforeBegin', p);
      }

    });


    //Cross out text when completed
    checkbox.onClick.listen((e) {
      description.className = (description.className == 'description') ? 'description-complete' : 'description';
    });

    //Set the text box back to empty
    (querySelector('#description-task') as TextInputElement).value = '';


    var draggable = Draggable(container,
        avatarHandler: AvatarHandler.clone() , verticalOnly: true, handle: '.drag');

    var dropzone = Dropzone(container);

    // Swap elements when dropped.
    dropzone.onDrop.listen((DropzoneEvent event) {
      swapElements(event.draggableElement, event.dropzoneElement);
    });
  }


}

void swapElements(Element elm1, Element elm2) {
  var parent1 = elm1.parent;
  var next1 = elm1.nextElementSibling;
  var parent2 = elm2.parent;
  var next2 = elm2.nextElementSibling;

  parent1.insertBefore(elm2, next1);
  parent2.insertBefore(elm1, next2);
}