Function.prototype.inherit = function(ParentClass) {
	this.prototype = Object.create(ParentClass.prototype);
	this.prototype.constructor = this;
	this.prototype.parent = ParentClass.prototype;
}

String.prototype.startsWith = function(prefix) {
    return this.indexOf(prefix) === 0;
};
