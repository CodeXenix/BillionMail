package domains

import (
	"context"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"

	"xenixmail-core/api/domains/v1"
	"xenixmail-core/internal/service/domains"
)

func (c *ControllerV1) DeleteDomain(ctx context.Context, req *v1.DeleteDomainReq) (res *v1.DeleteDomainRes, err error) {
	res = &v1.DeleteDomainRes{}

	if req.Domain == "" {
		return nil, gerror.New("Domain cannot be empty")
	}

	if err = domains.Delete(ctx, req.Domain); err != nil {
		return nil, err
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Domain,
		Log:  "Delete domain :" + req.Domain + " successfully",
	})

	res.SetSuccess("Domain deleted successfully")
	return
}
