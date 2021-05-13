module example.com/go-tests/create-account

go 1.16

replace example.com/go-tests/examples => ../examples

require (
	example.com/go-tests/examples v0.0.0-00010101000000-000000000000
	github.com/onflow/flow-go-sdk v0.19.0
	google.golang.org/grpc v1.37.1
)
