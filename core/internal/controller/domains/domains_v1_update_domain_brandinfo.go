package domains

import (
	"context"
	"github.com/gogf/gf/v2/util/gconv"
	"xenixmail-core/internal/consts"
	"xenixmail-core/internal/service/domains"
	"xenixmail-core/internal/service/public"

	"github.com/gogf/gf/v2/errors/gerror"

	"xenixmail-core/api/domains/v1"
)

func (c *ControllerV1) UpdateDomainBrandinfo(ctx context.Context, req *v1.UpdateDomainBrandinfoReq) (res *v1.UpdateDomainBrandinfoRes, err error) {
	res = &v1.UpdateDomainBrandinfoRes{}

	if req.Domain == "" {
		return nil, gerror.New("Domain cannot be empty")
	}

	updateData := map[string]interface{}{}

	domainName := req.Domain
	updateData["domain"] = domainName
	updateData["hasbrandinfo"] = req.HasBrandInfo

	if err = domains.Update(ctx, updateData); err != nil {
		return nil, err
	}

	_ = public.WriteLog(ctx, public.LogParams{
		Type: consts.LOGTYPE.Domain,
		Log:  "Update domain :" + req.Domain + "brandinfo : " + gconv.String(req.HasBrandInfo) + "successfully",
		Data: updateData,
	})

	res.SetSuccess("Domain updated brandinfo status successfully")
	return
}
