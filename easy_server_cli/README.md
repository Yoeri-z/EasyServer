# Welcome to the easy_server_cli

## introduction
This is the command line tool for easy server, a simple tool that allows you to create an easyserver and generate models and endpoints.

**You dont have to import this package into your pubspec.yaml!**

instead use 
```dart pub global activate easyserver_cli```

## requirements
You will need to have a dart sdk installation of version 3.0.0 or higher

## how it works
To create a new easyserver first run:

```dart pub global activate easyserver_cli```

then navigate to the directory where you want to start your project in a terminal and run:

```easyserver create {project name}```

in this project you will find a folder called **yourprojectname_generated** where there is a **models.yaml** file and **endpoinds.yaml** file, infomation on how to format these files will be commented inside them, after you have modified these files navigate to the directory they are in using the terminal and run:

```easyserver generate```

This will generate you models and endpoints, if you modify any of the files after you will need to run it again to make the changes

more documentation on how easyserver works can be found on the [github](https://github.com/Yoeri-z/EasyServer)