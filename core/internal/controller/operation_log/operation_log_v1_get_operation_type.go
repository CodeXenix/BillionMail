package operation_log

import (
	"context"
	"xenixmail-core/api/operation_log/v1"
	"xenixmail-core/internal/service/public"
)

func (c *ControllerV1) GetOperationType(ctx context.Context, req *v1.GetOperationTypeReq) (res *v1.GetOperationTypeRes, err error) {
	res = &v1.GetOperationTypeRes{}

	res.Data = public.LogTypeMap
	res.SetSuccess(public.LangCtx(ctx, "Get operation types successfully"))
	return res, nil
}
