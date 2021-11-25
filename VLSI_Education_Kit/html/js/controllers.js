var AupControllers = angular.module('AupControllers', []);

AupControllers.controller('IndexController', ['$scope', function($scope) {
	$scope.title = index.titles.title;
	$scope.libname = index.titles.libname;
	$scope.libtype = index.titles.libtype;

	console.log("Number of headers: "+ index.headers.length);
	$scope.headers = index.headers;
	$scope.modules = index.modules;

	console.log("Number of modules: "+ index.modules.length);
	for(i=0; i<index.modules.length; i++){
		console.log(index.modules[i])
		// console.log(index.modules[i].module[0].name);
	}
}]);