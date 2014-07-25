
class Object
	def dclone
		case self
		when Fixnum,Bignum,Float,NilClass,FalseClass,TrueClass
			klone = self
		when Hash
			klone = self.clone
			self.each { |k, v| klone[k] = v.dclone}
		when Array
			klone = self.clone
			klone.clear
			self.each { |v| klone << v.dclone}
		else
			klone = self.clone
		end
		klone.instance_variables.each do |v|
			klone.instance_variable_set(v, klone.instance_variable_get(v).dclone)
		end
		klone
	end
end
